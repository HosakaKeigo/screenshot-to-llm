#Requires AutoHotkey v2.0
#include ImagePut.ahk
#include JSON.ahk

; --- スクリーンショットを撮りBase64に変換する ---
CaptureScreenshotToBase64() {
    Send("#+s") ; Win+Shift+S でスクリーンショットを起動
    SavedClip := ClipboardAll() ; 現在のクリップボードを保存
    A_Clipboard := ""           ; クリップボードを空にする
    exe := "SnippingTool.exe"
    ProcessWait(exe)            ; スクリーンショット画面が表示されるのを待つ
    ProcessWaitClose(exe)       ; スクリーンショット画面が閉じるのを待つ

    Sleep 1000

    if !DllCall("IsClipboardFormatAvailable", "uint", 2) ; CF_BITMAPが存在するかチェック
        return SavedClip ; 存在しない場合は元のクリップボードを返す

    try {
        base64 := ImagePutBase64(ClipboardAll())
        return base64
    } catch as e {
        throw Error("Error converting to Base64: " e.Message)
    }
}

; --- Base64文字列をPOSTする ---
postWithBase64(endpoint, base64, bearerToken := "") {
    try {
        json_data := Map()
        json_data["image"] := base64

        ; InputBox でプロンプトを取得
        prompt_result := InputBox("プロンプトを入力してください", "プロンプト", , "これを説明してください。")

        ; キャンセルされた場合、または空白が入力された場合は関数を終了
        if (prompt_result.Result = "Cancel" || prompt_result.Value = "") {
            return "キャンセルしました。" ; または別の値を返すことも可能（エラーコードなど）
        }

        prompt := prompt_result.Value
        json_data["prompt"] := prompt
        json_str := jxon_dump(json_data)
        ;MsgBox(json_data, "test", 64)
        web := ComObject("WinHttp.WinHttpRequest.5.1")
        web.Open("POST", endpoint)
        web.SetRequestHeader("Content-Type", "application/json")
        if (bearerToken != "")
            web.SetRequestHeader("Authorization", "Bearer " bearerToken) ; Bearerトークンをセット
        web.Send(json_str)
        web.WaitForResponse()
        response := web.ResponseText
        return response
    } catch as e {
        throw Error("Error sending POST request: " e.Message)
    }
}

; Win + A でスクリーンショットを撮り、指定されたエンドポイントに送信
#a:: {
    try {
        base64 := CaptureScreenshotToBase64()
        if (base64 = "") {
            MsgBox("スクリーンショットが取得できませんでした。", "エラー", 16)
            return
        }
        ; ===== 以下を設定すること ====
        endpoint := "https://xxxxxxxxxxxxxx" ; エンドポイントをここに設定
        bearerToken := "xxxxxxxxxxxx" ; Bearerトークンを設定
        ; =========================
        response := postWithBase64(endpoint, base64, bearerToken)
        MsgBox(response, "コピーしました", 64)
        A_Clipboard := response

    } catch as e {
        MsgBox("Error: " e.Message, "Error", 16)
    }
}
