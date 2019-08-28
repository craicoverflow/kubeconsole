package main

import (
	"flag"
	"fmt"
	"oc-console/pkg/browser"
	"oc-console/pkg/kubeconfig"
)

func main() {

	kubeconfig := kubeconfig.Get()

	showURL := flag.Bool("url", false, "display URL in console")
	flag.Parse()

	if *showURL {
		fmt.Printf("Server URL: %s", kubeconfig.Host)
	} else {
		browser.Open(kubeconfig.Host)
	}
}
