package handler

import (
	"net/http"
	"os"
	"path"
	"strings"
)

func (h *WebHandler) RenderStaticFile(w http.ResponseWriter, r *http.Request) {
	staticDir := "./static"
	filePath := r.URL.Path
	isHtml := strings.HasSuffix(filePath, ".html")
	if filePath == "/static/" {
		isHtml = true
		filePath = path.Join(staticDir, "index.html")
	}

	fs := http.StripPrefix("/static/", http.FileServer(http.Dir(staticDir)))

	if isHtml {
		// KLUDGE: getting a content length error when tyring to use FileServer for html
		// so we read the file and write it to the response for now
		fileData, err := os.ReadFile(filePath)
		if err != nil {
			h.Logger.Error("unable to read file", "file", filePath, "error", err)
			http.Error(w, "file not found", http.StatusNotFound)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.WriteHeader(http.StatusOK)
		w.Write(fileData)
		return
	}
	fs.ServeHTTP(w, r)
	return
}
