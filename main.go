package main

import (
	"fmt"
	"runtime"
)

var appVersion = "dev"

func main() {
	fmt.Printf("Started qa-tester %s at => \n", appVersion)
	fmt.Printf("Runtime: %s\n", runtime.Version())
	fmt.Printf("OS: %s\n", runtime.GOOS)
	fmt.Printf("Arch: %s\n", runtime.GOARCH)
}
