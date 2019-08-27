package main

import (
	"fmt"
	"log"
	"os/exec"
	"regexp"
	"runtime"
)

func init() {
	_, err := exec.LookPath("oc")

	if err != nil {
		log.Fatal("oc binary missing")
	}
}

func main() {
	cmd := exec.Command("oc", "status")

	output, _ := cmd.Output()
	outputMsg := string(output[:])

	r := regexp.MustCompile(`https://.*`)
	matches := r.FindAllString(outputMsg, -1)

	url := matches[0]

	openBrowser(url)
}

func openBrowser(url string) {
	var err error

	switch runtime.GOOS {
	case "linux":
		err = exec.Command("xdg-open", url).Start()
	case "windows":
		err = exec.Command("rundll32", "url.dll,FileProtocolHandler", url).Start()
	case "darwin":
		err = exec.Command("open", url).Start()
	default:
		err = fmt.Errorf("unsupported platform")
	}
	if err != nil {
		log.Fatal(err)
	}
}
