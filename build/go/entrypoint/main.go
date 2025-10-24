package main

import (
	"os"
	"strings"
	"syscall"
	"time"
	"crypto/sha256"
	"fmt"

	"github.com/11notes/go"
)

const BIN_MC string = "/usr/local/bin/mc"
const BIN string = "/usr/local/bin/console"

var(
	Eleven eleven.New = eleven.New{}
)

func setup(){
	password, err := Eleven.Container.GetSecret("MINIO_CONSOLE_MINIO_PASSWORD", "MINIO_CONSOLE_MINIO_PASSWORD_FILE")
	if err != nil {
		Eleven.LogFatal("you must set MINIO_CONSOLE_MINIO_PASSWORD or MINIO_CONSOLE_MINIO_PASSWORD_FILE!")
	}

	_, err = Eleven.Util.Run(BIN_MC, []string{"alias", "set", "minio", os.Getenv("MINIO_CONSOLE_MINIO_URL"), os.Getenv("MINIO_CONSOLE_MINIO_USER"), password})
	if err != nil{
		Eleven.LogFatal("alias failed: %v", err)
	}else{
		password, err := Eleven.Container.GetSecret("MINIO_CONSOLE_PASSWORD", "MINIO_CONSOLE_PASSWORD_FILE")
		if err != nil {
			Eleven.LogFatal("you must set MINIO_CONSOLE_PASSWORD or MINIO_CONSOLE_PASSWORD_FILE!")
		}

		mc("admin user add minio " + os.Getenv("MINIO_CONSOLE_USER") + " " + password)
		mc("admin policy create minio " + os.Getenv("MINIO_CONSOLE_POLICY_NAME") + " /minio-console/etc/policy." + os.Getenv("MINIO_CONSOLE_POLICY") + ".json")
		mc("admin policy attach minio " + os.Getenv("MINIO_CONSOLE_POLICY_NAME") + " --user=" + os.Getenv("MINIO_CONSOLE_USER"))
	}
}

func mc(cmd string){
	out, err := Eleven.Util.Run(BIN_MC, strings.Split(cmd, " "))
	if err != nil{
		Eleven.LogFatal("command failed: %v", err)
	}else{
		Eleven.Log("INF", "%s", strings.TrimRight(out, "\r\n"))
	}
}

func random() string{
	h := sha256.New()
	h.Write([]byte(time.Now().Format(time.RFC3339)))
	bs := h.Sum(nil)
	return fmt.Sprintf("%x", bs)
}

func main() {
	setup()
	env := append(
		os.Environ(),
		"CONSOLE_PBKDF_PASSPHRASE=" + random(),
		"CONSOLE_PBKDF_SALT=" + random(),
		"CONSOLE_MINIO_SERVER=" + os.Getenv("MINIO_CONSOLE_MINIO_URL"),
	)
	if err := syscall.Exec(BIN, []string{"console", "server", "--certs-dir", "/minio-console/ssl"}, env); err != nil {
		os.Exit(1)
	}
}