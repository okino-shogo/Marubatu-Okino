//
//  ContentView.swift
//  Marubatu
//
//  Created by 沖野匠吾 on 2025/02/15.
//

import SwiftUI

struct Quiz: Identifiable,Codable {
    var id = UUID()//それぞれの設問を区別するID
    var question: String//問題文
    var answer: Bool//解答
}



struct ContentView: View {

    // 問題
    let quizeExamples: [Quiz] = [
        Quiz(question: "iPhoneアプリを開発する統合環境はZcodeである", answer: false),
        Quiz(question: "Xcode画面の右側にはユーティリティーズがある", answer: true),
        Quiz(question: "Textは文字列を表示する際に利用する", answer: true)
    ]

    @AppStorage("quiz") var quizzesData = Data()//UserDefaultsから問題を読み込む(Data型)
    @State var quizzesArray: [Quiz] = []//問題を入れておく配列
    
    @State var currentQuestionNum = 0//今、何問目の数字
    @State var showingAlert = false //アラートの表示・非表示を制御
    @State var alertTitle = ""//"正解"か"不正解"の文字を入れるための変数

    //画面生成時にquizzesDateに読み込んだDate型の値を[Quiz]型にデコードしてquizzesArrayに入れる
    init(){
        if let decodedQuizzes = try? JSONDecoder().decode([Quiz].self, from: quizzesData){
            _quizzesArray = State(initialValue: decodedQuizzes)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack{
                VStack {
                    Text(showQuestion()) // 問題文を表示
                        .padding()//余白を外側に追加
                        .frame(width: geometry.size.width*0.85, alignment: .leading)//横幅を250、左寄せに
                        .fontDesign(.rounded) //フォントのデザインを変更
                        .background(.yellow)

                    Spacer()
                    //0Xボタンを横並びにするためにHStackを使う
                    HStack{
                        Button {
                            //                        print("◯")//ボタンが押された時の動作
                            checkAnswer(yourAnswer: true)
                        } label: {
                            Text("◯")//ボタンの見た目
                        }
                        .frame(width: geometry.size.width*0.4, height: geometry.size.width*0.4)//幅と高さを190に
                        .font(.system(size:100, weight: .bold))//フォントサイズを100、太字に
                        .background(.red)//背景を赤に
                        .foregroundStyle(.white)//文字の色を白に
                        
                        Button {
                            //print("×")//ボタンが押された時の動作
                            checkAnswer(yourAnswer: false)
                        } label: {
                            Text("×")//ボタンの見た目
                        }
                        .frame(width: geometry.size.width*0.4, height: geometry.size.width*0.4)//幅と高さを親ビューの幅の0.4倍に
                        .font(.system(size:100, weight: .bold))//フォントサイズを100、太字に
                        .background(.blue)//背景を赤に
                        .foregroundStyle(.white)//文字の色を白に
                        
                    }
                }
                .padding()
                .navigationTitle("マルバツクイズ") // ナビゲーションバーにタイトル設定
                //回答時のアラート
                .alert(alertTitle, isPresented: $showingAlert){
                    Button("OK",role: .cancel){}
                }
                .toolbar {

                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink{
                            CreateView(quizzesArray: $quizzesArray)
                                .navigationTitle("問題を作ろう")
                                .onDisappear {
                                    currentQuestionNum = 0
                                }
                        }label:{
                            Image(systemName: "plus")
                                .font(.title)
                        }
                    }
                }
            }
            
        }
    }
    
    //問題文を表示させるための関数
    func showQuestion() -> String {
        var question = "問題がありません"
        
        if !quizzesArray.isEmpty {
            let quiz = quizzesArray[currentQuestionNum]
            question = quiz.question
        }
        return question
    }
    
    //回答をチェックする関数、正解なら次の問題を表示
    func checkAnswer(yourAnswer: Bool) {
        if quizzesArray.isEmpty {
            return
        }
        let quiz = quizzesArray[currentQuestionNum]
        let ans = quiz.answer
        if yourAnswer == ans {
            alertTitle = "正解！"
            if currentQuestionNum + 1 < quizzesArray.count {
                currentQuestionNum += 1 //次の問題に進む
            }else {
                //超えたときは0に戻す
                currentQuestionNum = 0
            }
            
        }else {
            alertTitle = "不正解"
        }
        showingAlert = true //アラートを表示
    }
    
}

#Preview {
    ContentView()
}
