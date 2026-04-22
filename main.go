package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Println("Me launched on")
	fmt.Printf("Ver: %s\n", runtime.Version())
	fmt.Printf("OS: %s\n", runtime.GOOS)
	fmt.Printf("Architecture: %s\n", runtime.GOARCH)
}
