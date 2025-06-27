# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

本プロジェクトはPDFプレビューやWebViewに関するスクロール検知の調査のためのプロジェクトです

## パッケージのインストール

パッケージのインストールは**必ず**Flutterコマンドを使ってインストールしてください。

## 技術調査方法

技術調査に関して、学習データのみをあてにせず、適宜Web検索を行って情報を集めてください。
Web検索方法は以降に記載します。

### GeminiによるWeb検索

`gemini` はgoogleのGemini CLIを呼び出すコマンドです. このコマンドではWeb検索が可能です.

検索を利用する際のコマンドは `gemini -p 'WebSearch: ...'`.

```bash
gemini -p "WebSearch: ..."
```

## ペアプログラミング

技術部分でGeminiとペアプログラミングを行い、それをコードに反映してください

Geminiに意見を求めるときのコマンドは `gemini -p '...'`.

```bash
gemini -p "..."
```
