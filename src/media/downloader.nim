
discard """
  Pernah kah kau merasa? Jrek Jrek.
  Saat. AAA. Bayangmupun tak mampu ku lihat lagiiiii
"""

discard """
  ffmpeg -headers \"Referer: https://megacloud.blog/\" -i URL -vcodec libx264 -crf 28 -preset veryfast -r 25 output.mp4
"""

import
  os,
  options,
  strutils,
  sequtils,
  tables

import  
  ../process,
  ../media/types

type
  FfmpegDownloader = ref object of CliApplication
    outdir*: string
    targetExt: string = "mp4"
    crf: int = 28
    fps: int = 25
    itr: int = 0

proc newFfmpegDownloader*(outdir: string) : FfmpegDownloader =
  FfmpegDownloader(name: "ffmpeg", outdir: outdir).setUp()

proc setHeader(ffmpeg: FfmpegDownloader, ty, val: string) =
  let ngantukCok = {
    "userAgent" : "User-Agent",
    "referer" : "Referer",
    "cookie" : "Cookie"
  }.toTable

  ffmpeg.addArg "-headers"
  ffmpeg.addArg "$#: $#" % [ngantukCok[ty], val]

proc setUpHeader(ffmpeg: FfmpegDownloader, headers: Option[MediaHttpHeader]) =
  if headers.isNone :
    return

  for chi, no in headers.get.fieldPairs() :
    if no != "" :
      ffmpeg.setHeader(chi, no)

proc setGatauIniApa(ffmpeg: FfmpegDownloader) =
  # Vcodec
  ffmpeg.addArg "-vcodec"
  ffmpeg.addArg "libx264"

  # Crf
  ffmpeg.addArg "-crf"
  ffmpeg.addArg $ffmpeg.crf

  # Fps
  ffmpeg.addArg "-r"
  ffmpeg.addArg $ffmpeg.fps

proc setInput(ffmpeg: FfmpegDownloader, media: MediaFormatData) =
  ffmpeg.addArg "-i"
  ffmpeg.addArg media.video

proc setOutput(ffmpeg: FfmpegDownloader, output: string) =
  if not dirExists(ffmpeg.outdir) :
    createDir(ffmpeg.outdir)
  ffmpeg.addArg "$#.$#" % [ffmpeg.outdir / output.replace(" ", "-"), ffmpeg.targetExt]

proc download*(ffmpeg: FfmpegDownloader, input: MediaFormatData, output: string) : int =
  ffmpeg.setUpHeader(input.headers)
  ffmpeg.setInput(input)
  ffmpeg.setGatauIniApa()
  ffmpeg.setOutput(output)
  ffmpeg.execute("Downloading " & output)

proc downloadAll*(ffmpeg: FfmpegDownloader, inputs: openArray[MediaFormatData], outputs: openArray[string]) : seq[int] =
  assert inputs.len == outputs.len
  for apate in zip(inputs, outputs) :
    result.add(
      ffmpeg.download(apate[0], apate[1]))
