
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
  tables,
  ../process,
  ../media/types

type
  FfmpegDownloader = ref object of CliApplication
    outdir*: string = "."
    crf: int = 28
    fps: int = 25
    itr: int = 0

proc newFfmpegDownloader() : FfmpegDownloader =
  result.name = "ffmpeg"
  result.setUp()

proc setHeader(ffmpeg: FfmpegDownloader, ty, val: string) =
  let ngantukCok = {
    "userAgent" : "User-Agent",
    "referer" : "Referer",
    "cookie" : "Cookie"
  }.toTable

  ffmpeg.addArg "-headers"
  ffmpeg.addArg "$#: $#" % [ngantukCok[ty], val]

proc setUpHeader(ffmpeg: FfmpegDownloader, headers: Option[MediaHttpHeader]) =
  if headers.isSome :
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
  ffmpeg.addArg ffmpeg.outdir / output

proc download*(ffmpeg: FfmpegDownloader, input: MediaFormatData, output: string) : int =
  ffmpeg.setUpHeader(input.headers)
  ffmpeg.setInput(input)
  ffmpeg.setGatauIniApa()
  ffmpeg.setOutput(output)
  ffmpeg.execute()

proc downloadAll*(ffmpeg: FfmpegDownloader, inputs: openArray[MediaFormatData], outputs: openArray[string]) : seq[int] =
  assert inputs.len == outputs.len
  for apate in zip(inputs, outputs) :
    result.add(
      ffmpeg.download(apate[0], apate[1]))

when isMainModule  :
  var
    palla = MediaHttpHeader(
      userAgent: "Mozilla",
      referer: "https://animepahe.si/"
    )
    media = MediaFormatData(
      video: "https://vault-09.uwucdn.top/stream/09/13/24c3b66ebb38310566676549c7df78b458633edd4b63a4f9bb26f704e4f319ca/uwu.m3u8",
      typeExt: extM3u8,
      headers: palla.some
    )
    rijal = newFfmpegDownloader()

  discard rijal.setUp()
  discard rijal.downloadAll([media], ["episode1.mp4"])
