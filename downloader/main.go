package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"

	"github.com/joho/godotenv"
	"github.com/vbauerster/mpb/v7"
	"github.com/vbauerster/mpb/v7/decor"
)

func download(url string, wg *sync.WaitGroup, p *mpb.Progress) {
	defer wg.Done()

	response, err := http.Get(url)
	if err != nil {
		panic(err)
	}
	defer response.Body.Close()

	urlParts := strings.Split(url, "/")
	fileName := urlParts[len(urlParts)-1]

	out, err := os.Create("models/" + fileName)
	if err != nil {
		panic(err)
	}
	defer out.Close()

	bar := p.AddBar(response.ContentLength,
		mpb.PrependDecorators(
			decor.Name(fileName),
			decor.CountersKibiByte("% .2f / % .2f"),
		),
		mpb.AppendDecorators(
			decor.OnComplete(
				decor.EwmaETA(decor.ET_STYLE_MMSS, 60), "done",
			),
		),
	)

	proxyReader := bar.ProxyReader(response.Body)
	_, err = io.Copy(out, proxyReader)
	if err != nil {
		log.Fatal(err)
	}

	bar.Abort(false)
	println("Downloaded: ", url)
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
	var wg sync.WaitGroup
	p := mpb.New(mpb.WithWaitGroup(&wg), mpb.WithWidth(60))

	for _, url := range os.Environ() {
		if strings.HasPrefix(url, "MODEL_URL_") {
			wg.Add(1)
			go download(strings.Split(url, "=")[1], &wg, p)
		}
	}

	p.Wait()
	println("All downloads finished.")
}
