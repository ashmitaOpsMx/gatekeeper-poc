package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/OpsMx/go-app-base/httputil"
	"go.uber.org/zap"
)

func OPAPocPOST(w http.ResponseWriter, req *http.Request) {
	defer req.Body.Close()

	data, err := io.ReadAll(req.Body)
	if err != nil {
		httputil.SetError(w, http.StatusBadRequest, err.Error())
		return
	}

	fmt.Println(string(data))
	fmt.Println("----------------")
	zap.S().Info(string(data))

}

func OPAGatePocGET(w http.ResponseWriter, req *http.Request) {

	file, err := os.Open("/app/my_bundle.tar.gz")
	if err != nil {
		httputil.SetError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer file.Close()

	// Set the Content-Type header to indicate that it's a gzipped tarball.
	w.Header().Set("Content-Type", "application/gzip")

	// Write the gzipped tarball to the response writer.
	if _, err := io.Copy(w, file); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

type reponse struct {
	Allow bool `json:"allow,omitempty" yaml:"allow"`
}

func OPAGatePocPOST(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("content-type", "application/json")
	response := reponse{
		Allow: true,
	}
	data, _ := json.Marshal(response)
	httputil.CheckedWrite(w, data)
}
