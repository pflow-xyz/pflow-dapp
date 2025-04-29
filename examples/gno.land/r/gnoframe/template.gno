package gnoframe

import (
	"net/url"
	"strings"
)

func init() {
	_ = strings.TrimSpace
}

type GnoObj struct {
	obj map[string]interface{}
}

type Component interface {
	Render(opts map[string]interface{}) string
}

func isValidHelper(fn interface{}) bool {
	switch fn.(type) {
	case func(opts map[string]interface{}) string,
		func(string) string,
		func() string,
		string:
		return true
	default:
		return false
	}
}

// use registry to populate available helpers
func (nob *GnoObj) renderHelper(path string) string {
	if f, ok := nob.obj[path]; ok {
		switch f := f.(type) {
		// case func(opts map[string]interface{}) string:
		// return f(nob.Context(path).(map[string]interface{}))
		case func(string) string:
			return f(path)
		case func() string:
			return f()
		case string:
			return f
		default:
			return "unknown type"
		}
	}
	return "not found"
}

func (nob *GnoObj) Context(path string) map[string]string {
	opts := make(map[string]interface{})
	for k, v := range nob.obj {
		_ = v
		opts[k] = nob.renderHelper(k)
	}
	opts["path"] = path
	// FIXME
	_ = opts
	return map[string]string{}
}

func IsValidHelper(fn interface{}) bool {
	switch fn.(type) {
	case func(string) string:
		return true
	default:
		return false
	}
}

func RegisterHelper(name string, fn interface{}) {
	if !isValidHelper(fn) {
		panic("Invalid helper function type")
	}
	registry.obj["helper::"+name] = fn
}

func GetHelper(name string) func(string) string {
	return registry.obj["helper::"+name].(func(string) string)
}

/*
func renderTemplate(template string, ctx map[string]string) string {
    var output string
    var i, n int
    n = len(template)
    for i < n {
        if template[i] == '{' {
            // find closing brace
            var j = i + 1
            for j < n && template[j] != '}' {
                j++
            }
            if j < n {
                var tag = template[i+1:j]
                output += resolveTag(tag, ctx)
                i = j + 1
            } else {
                // unmatched '{', just append
                output += string(template[i])
                i++
            }
        } else {
            output += string(template[i])
            i++
        }
    }
    return output
}
*/

// formatter to escape path variables
func pathEsc(v string) string {
	return url.PathEscape(v)
}

// REVIEW: does this support { varname|pathEsc } syntax?
/*
func resolveTag(tag string, ctx map[string]string) string {
    var parts = strings.Split(tag, " ")
    if len(parts) == 1 {
        // Simple variable replacement
        if val, ok := ctx[parts[0]]; ok {
            return val
        }
        return "" // undefined variable
    } else if len(parts) == 2 {
        var helperName = parts[0]
        var argName = parts[1]
        if helper, ok := helpers[helperName]; ok {
            var argVal = ctx[argName]
            return helper(argVal)
        }
        return "" // undefined helper
    }
    return "" // malformed
}
*/
