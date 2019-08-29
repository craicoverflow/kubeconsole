package main

import (
	"flag"
	"fmt"
	"kubeconsole/pkg/browser"
	"kubeconsole/pkg/kubeconfig"
)

func main() {
	kubeconfig := kubeconfig.Get()

	showURL := flag.Bool("url", false, "display URL in console")
	flag.Parse()

	if *showURL {
		fmt.Printf("Server URL: %s", kubeconfig.Host)
	} else {
		fmt.Println("Opening in browser...")
		browser.Open(kubeconfig.Host)
	}
}
