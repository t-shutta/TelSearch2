//
//  ViewController.swift
//  TelSearch2
//
//  Created by medipad-no-MacBook-Pro on 2022/08/09.
//

import UIKit
import WebKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    //リクエスト先のスプレッドシートURL定義
    //本番
//    let urlString = "https://script.google.com/a/macros/mediceo-gp.com/s/AKfycbwP4SNerlCzPpErThm9HogBC3URF1HludPQPDAA72nINUMbc6LsiPHR3IjJ9KUDSk8H/exec"
    
    //開発
    let urlString = "https://script.google.com/macros/s/AKfycbwg_lnCOipmVhquGHhlF0lQfXLJsEk2XXMo4J13Ih-mBfOl_uWQZ0pJ3nIa4rABq18L/exec"

    // 初期画面生成
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Search Barのdelegate通知先を設定
        searchText.delegate = self
        // Table ViewのdataSourceを設定
        tableView.dataSource = self
        // Table Viewのdelegateを設定
        tableView.delegate = self
        // セルの高さ
        tableView.rowHeight = 49
        
        // 認証チェック




        //WKWebViewを生成
//        webView = WKWebView(frame:CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))

        
        
//
//        //URL設定
//        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
//
//        let url = NSURL(string: encodedUrlString!)
//        let request = NSURLRequest(url: url! as URL)
//        print(url)
//        //webViewリクエスト開始
//        webView.load(request as URLRequest)
//
//        //nabigationBarを覆う形でwebViewを追加する
//        self.navigationController?.view.addSubview(webView)
//        webView.navigationDelegate = self
//
//        ///*プルリフレッシュ用処理
//        self.tableView.refreshControl = refreshCtl
//        refreshCtl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
//        //*/

        
        
        
        
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    // 検索ボタンをクリック（タップ）時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)

        if let searchWord = searchBar.text {
            // デバックエリアに出力
            print(searchWord)
            // 入力されていたら、お菓子を検索
            searchTel(keyword: searchWord)
        }
    }

    // Identifialeプロトコルを利用して、電話帳情報をまとめる構造体を定義する
    struct TelItem: Identifiable {
        let id = UUID()
        let BranchName: String
        let Manager: String
        let TelNo: String
    }
    // 電話帳のリクエスト（Identifiableプロトコル）
    var telList: [TelItem] = []

    // JSONのitem内のデータ構造
    struct Item: Codable {
        // 支店名
        let BranchName: String?
        // 支店長名
        let Manager: String?
        // 電話番号
        let TelNo: String?
    }
    
    // 検索処理
    func searchTel(keyword: String) {
        // 電話帳の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}

        // リクエストURLの組み立て
        guard let req_url = URL(string: urlString + "?searchkey=\(keyword_encode)") else {return}

        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)

        // リクエストURLの組み立て
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)

        //        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, respose, error) in
            // セッションを終了
            session.finishTasksAndInvalidate()

            // do try catch エラーハンドリング
            do {
                // JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                // 受け取ったJSONデータをパースして格納
                guard let items: [Item] = try? decoder.decode([Item].self, from: data!) else {return}

                // 電話帳リストを初期化
                self.telList.removeAll()

                // 取得している支店の数だけ処理
                for item in items {
                    // 支店名、支店長名、電話番号をアンラップ
                    if let name = item.BranchName,
                       let manager = item.Manager,
                       let telno = item.TelNo {
                        // １つの支店を構造体でまとめて管理
                        let branch = TelItem(BranchName: name, Manager: manager, TelNo: telno)
                        self.telList.append(branch)
                    }
                }
                // Table Viewを更新する
                self.tableView.reloadData()
            } catch {
                // エラー処理
                print("エラーが出ました")
            }
        })

        // ダウンロード開始
        task.resume()
    }
    
    // Cellの端数を返すdataSourceメソッド、必ず記述する必要があります
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return telList.count
    }

    // Cellに値を設定するdatasourceメソッド、必ず記述する必要がある
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 今回表示を行う、Cellオブジェクト（１行）を取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "telCell", for: indexPath)

        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        let label3 = cell.contentView.viewWithTag(3) as! UILabel

        // お菓子のタイトル設定
        label1.text = telList[indexPath.row].BranchName
        label2.text = telList[indexPath.row].Manager
        label3.text = telList[indexPath.row].TelNo
        // 設定済みのCellオブジェクトを画面に反映
        return cell
    }

    // Cellが選択された際に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)

        guard let telUrl = URL(string: "tel://" + telList[indexPath.row].TelNo) else {return}
        UIApplication.shared.open(telUrl)

    }

//************************************************************************
//    struct WebView: UIViewRepresentable {
//        var webView = WKWebView()
//        var urlString: String
//
//        class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
//            var parent: WebView
//
//            init(_ parent: WebView) {
//                self.parent = parent
//            }
//
//            // "target="_blank""が設定されたリンクも開けるようにする
//            func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//                if navigationAction.targetFrame == nil {
//                    webView.load(navigationAction.request)
//                }
//                return nil
//            }
//
//            // URLごとに処理を制御する
//            func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
//                if let url = navigationAction.request.url?.absoluteString {
//                    if (url.hasPrefix("https://apps.apple.com/")) {
//                        guard let appStoreLink = URL(string: url) else {
//                            return
//                        }
//                        UIApplication.shared.open(appStoreLink, options: [:], completionHandler: { (succes) in
//                        })
//                        decisionHandler(WKNavigationActionPolicy.cancel)
//                    } else if (url.hasPrefix("http")) {
//                        decisionHandler(WKNavigationActionPolicy.allow)
//                    } else {
//                        decisionHandler(WKNavigationActionPolicy.cancel)
//                    }
//                }
//            }
//
//            // 表示しているページ情報
//            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//                // 表示しているページのタイトル
//                print(webView.title ?? "")
//                //print("webview処理呼び出し")
//                let url = webView.url?.absoluteString ?? ""
//                // 表示しているページのURL
//                print(url)
//
//                if(url.contains("https://script.googleusercontent.com")){
//                    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() {(cookies) in
//                        for eachcookie in cookies {
//                            //スプレッドシートを開くにあたって必要だと思われる「google.co.jp」のクッキーを保存しデータのフェッチを行う
//    //                        if eachcookie.domain.contains("google.co.jp"){
//    //                            webView.isHidden = true
//    //                        }
//                            print("<cokkie>")
//                            print(eachcookie.domain)
//                        }
//                    }
//    //                webView.isHidden = true
//    //                webView.frame(height: 0)
//                    webView(frame: CGRect(height: 0))
//                }
//            }
//        }
//
//        func makeCoordinator() -> Coordinator {
//            Coordinator(self)
//        }
//
//        func makeUIView(context: Context) -> WKWebView {
//            return webView
//        }
//
//        func updateUIView(_ webView: WKWebView, context: Context) {
//            // makeCoordinatorで生成したCoordinatorクラスのインスタンスを指定
//            webView.uiDelegate = context.coordinator
//            webView.navigationDelegate = context.coordinator
//            print(context)
//            // スワイプで画面遷移できるようにする
//            webView.allowsBackForwardNavigationGestures = true
//
//            guard let url = URL(string: urlString) else {
//                return
//            }
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
//
//        // 前のページに戻る
//        func goBack() {
//            webView.goBack()
//        }
//
//        // 次のページに進む
//        func goForward() {
//            webView.goForward()
//        }
//
//        // ページをリロードする
//        func reload() {
//            webView.reload()
//        }
//
//        class AllowsSelfSignedCertificateDelegate: NSObject, URLSessionDelegate {
//            func urlSession(_ session: URLSession,
//                           didReceive challenge: URLAuthenticationChallenge,
//                           completionHandler: @escaping (URLSession.AuthChallengeDisposition,
//                                                         URLCredential?) -> Void) {
//                let protectionSpace = challenge.protectionSpace
//                guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
//                      protectionSpace.host == "sso.mediceo.private",
//                      let serverTrust = protectionSpace.serverTrust else {
//                        // 特別に検証する対象ではない場合はデフォルトのハンドリングを行う
//                        completionHandler(.performDefaultHandling, nil)
//                        return
//                      }
//                // 通信を継続して問題ない場合は、URLCredentialオブジェクトを作って返す
//                completionHandler(.useCredential, URLCredential(trust: serverTrust))//許可
//            }
//        }
//    }

}

