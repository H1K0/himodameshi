package server

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
)

// problem — ошибка API по RFC 9457. Обработчики возвращают её как обычную ошибку,
// а ответ формирует handleErrors, поэтому формат один для всех маршрутов.
type problem struct {
	status     int
	code       string
	detail     string
	fields     []api.FieldError
	retryAfter int
	cable      *api.Cable
}

func (p *problem) Error() string { return p.code }

var (
	errUnauthorized        = &problem{status: http.StatusUnauthorized, code: "unauthorized"}
	errInvalidCredentials  = &problem{status: http.StatusUnauthorized, code: "invalid_credentials"}
	errTelegramAuthInvalid = &problem{status: http.StatusUnauthorized, code: "telegram_auth_invalid"}
	errTelegramNotLinked   = &problem{status: http.StatusUnauthorized, code: "telegram_not_linked"}
	errWrongPassword       = &problem{status: http.StatusBadRequest, code: "wrong_password"}
	errOriginMismatch      = &problem{status: http.StatusForbidden, code: "origin_mismatch"}
	errNicknameTaken       = &problem{status: http.StatusConflict, code: "nickname_taken"}
	errTelegramTaken       = &problem{status: http.StatusConflict, code: "telegram_taken"}
	errOwnerWithMembers    = &problem{status: http.StatusConflict, code: "owner_with_members"}
	errNoTeamAccess        = &problem{status: http.StatusForbidden, code: "no_team_access"}
	errOwnerOnly           = &problem{status: http.StatusForbidden, code: "owner_only"}
	errNotFound            = &problem{status: http.StatusNotFound, code: "not_found"}
	errNotAMember          = &problem{status: http.StatusConflict, code: "not_a_member"}
	errPersonalTeam        = &problem{status: http.StatusConflict, code: "personal_team"}
	errOwnerCannotLeave    = &problem{status: http.StatusConflict, code: "owner_cannot_leave"}
	errCableArchived       = &problem{status: http.StatusConflict, code: "cable_archived"}
	errCableTypeLocked     = &problem{status: http.StatusConflict, code: "cable_type_locked"}
	errInternal            = &problem{status: http.StatusInternalServerError, code: "internal_error"}
)

func validationError(fields ...api.FieldError) *problem {
	return &problem{
		status: http.StatusBadRequest,
		code:   "validation_error",
		detail: "Запрос не прошёл проверку",
		fields: fields,
	}
}

// versionConflict — отказ в правке устаревшей версии кабеля; актуальный кабель уходит в теле ответа.
func versionConflict(cable api.Cable) *problem {
	return &problem{status: http.StatusConflict, code: "version_conflict", cable: &cable}
}

func (p *problem) body() api.Problem {
	body := api.Problem{
		Type:   "about:blank",
		Title:  http.StatusText(p.status),
		Status: p.status,
		Code:   p.code,
	}
	if p.detail != "" {
		body.Detail = &p.detail
	}
	if len(p.fields) > 0 {
		body.Errors = &p.fields
	}
	return body
}

func writeProblemBody(c *gin.Context, status int, body any) {
	data, err := json.Marshal(body)
	if err != nil {
		c.Status(http.StatusInternalServerError)
		return
	}
	c.Data(status, "application/problem+json", data)
}

func writeProblem(c *gin.Context, p *problem) {
	if p.retryAfter > 0 {
		c.Header("Retry-After", strconv.Itoa(p.retryAfter))
	}
	if p.cable != nil {
		body := p.body()
		writeProblemBody(c, p.status, api.VersionConflictProblem{
			Type:   body.Type,
			Title:  body.Title,
			Status: body.Status,
			Code:   body.Code,
			Cable:  p.cable,
		})
		return
	}
	writeProblemBody(c, p.status, p.body())
}

// handleErrors превращает ошибки обработчиков в ответы application/problem+json.
func (s *Server) handleErrors(c *gin.Context) {
	c.Next()

	if len(c.Errors) == 0 || c.Writer.Written() {
		return
	}
	err := c.Errors.Last().Err

	var p *problem
	switch {
	case errors.As(err, &p):
	case c.Writer.Status() == http.StatusBadRequest:
		// Сгенерированный код не смог разобрать тело запроса.
		p = validationError(api.FieldError{Field: "body", Message: "некорректный JSON"})
	default:
		s.log.ErrorContext(c, "request failed", "method", c.Request.Method, "path", c.FullPath(), "error", err)
		p = errInternal
	}
	writeProblem(c, p)
}
