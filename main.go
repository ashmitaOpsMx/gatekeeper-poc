package main

import (
	"context"
	"flag"
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"github.com/OpsMx/go-app-base/version"
	"go.uber.org/zap"
)

const (
	appName               = "opa-gate-poc"
	defaultHTTPListenPort = 8500
)

var (
	logger      *zap.Logger
	sl          *zap.SugaredLogger
	showversion = flag.Bool("version", false, "show the version and exit")
)

func main() {
	log.Printf("%s", version.VersionString())
	flag.Parse()
	if *showversion {
		os.Exit(0)
	}

	var err error
	if logger, err = zap.NewProduction(); err != nil {
		log.Fatalf("setting up logger: %v", err)
	}
	defer func() {
		_ = logger.Sync()
	}()
	_ = zap.ReplaceGlobals(logger)
	sl = logger.Sugar()
	sl.Infow("starting",
		"appName", appName,
		"version", version.VersionString(),
		"gitBranch", version.GitBranch(),
		"gitHash", version.GitHash(),
		"buildType", version.BuildType(),
		"os", runtime.GOOS,
		"arch", runtime.GOARCH,
		"cores", runtime.NumCPU(),
	)

	sigchan := make(chan os.Signal, 1)
	signal.Notify(sigchan, syscall.SIGTERM, syscall.SIGINT)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go runHTTPServer(ctx)

	sig := <-sigchan
	sl.Infow("clean exit", "signal", sig)

}
