# Screenshot to LLM
スクリーンショットをもとにLLMに質問するためのAutoHotKey

## セットアップ
### AutoHotKeyのインストール
Ver.2を使ってください。

https://www.autohotkey.com/

### ファイルの設置
- ImagePut.ahk
- JSON.ahk
- screenshot-to-llm.ahk

を`Documents/AutoHotkey`以下に格納する。

### Secretの設定
`screenshot-to-llm.ahk`の

- endpoint
- bearerToken

を設定。（LLMのバックエンド。）

バックエンドは

```json
{
  image: <Base64>,
  prompt: <prompt>
}
```

を受け取り、stringを返すインターフェース。


### ファイルの実行
- `screenshot-to-llm.ahk`をダブルクリック。
- `Win + A`で実行。