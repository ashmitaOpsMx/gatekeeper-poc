package main

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gorilla/mux/otelmux"
	"go.uber.org/zap"
)

const (
	pocApi     = "/bundle.tar.gz"
	postApi    = "/api/v1/poc"
	postOpaApi = "/api/v1/opapoc"
)

func loggingMiddleware(next http.Handler) http.Handler {
	return handlers.LoggingHandler(os.Stdout, next)
}

func runHTTPServer(ctx context.Context) {

	r := mux.NewRouter().SkipClean(true).UseEncodedPath()

	r.HandleFunc(pocApi, OPAGatePocGET).Methods(http.MethodGet)
	r.HandleFunc(postApi, OPAGatePocPOST).Methods(http.MethodPost)
	r.HandleFunc(postOpaApi, OPAPocPOST).Methods(http.MethodPost)

	r.Use(loggingMiddleware)
	r.Use(otelmux.Middleware(appName))

	srv := &http.Server{
		Addr:    fmt.Sprintf(":%d", defaultHTTPListenPort),
		Handler: r,
	}

	zap.S().Infow("OPAGatePoc API HTTP server started", "listenAddress", srv.Addr)
	zap.S().Fatal(srv.ListenAndServe())
}
