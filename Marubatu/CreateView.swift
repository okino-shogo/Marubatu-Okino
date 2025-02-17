//
//  CreateView.swift
//  Marubatu
//
//  Created by 沖野匠吾 on 2025/02/15.
//

import SwiftUI


struct CreateView: View {
    @Binding var quizzesArray: [Quiz] // 回答画面で読み込んだ問題を受け取る
    @State private var questionText = ""//テキストフィールドの文字を受け取る
    @State private var selectAnswer = "O"
    let answers = ["O","X"]//ピッカーの選択肢一覧
    var body: some View {

        VStack {
            Text("問題文と解答を入力して、追加ボタンを押してください。")
                .foregroundStyle(.gray)
                .padding()

            //問題文を入力するテキストフィールド
            TextField(text: $questionText){
                Text("問題文を入力してください")
            }
            .padding()
            .textFieldStyle(.roundedBorder)

            Picker("解答", selection: $selectAnswer) {
                ForEach(answers, id: \.self){answers in
                    Text(answers)
                }
            }
            .pickerStyle(.segmented)
            .padding()


            Button {
                //追加ボタンが押された時の処理
                addQuiz(question: questionText, answer: selectAnswer)
                print(quizzesArray)
            } label: {
                Text("追加")
            }
            .padding()
            Button {
                quizzesArray.removeAll()
                UserDefaults.standard.removeObject(forKey: "quiz")

            } label: {
                Text("全削除")
            }
            .foregroundStyle(.red)
            .padding()

            List{
                ForEach(quizzesArray){quiz in
                    //横ならび
                    HStack{
                        Text(quiz.question)
                        //空白開ける
                        Spacer()
                        //answerはtrueかfalseで文字列にしないといけない
                        Text(quiz.answer ?"解答:O":"解答:X")
                    }
                }
                //リストの並び替え時の処理を設定
                .onMove(perform: { from, to in
                    replaceRow(from, to)
                })
                .onDelete(perform: rowRemove)
            }
            .toolbar(content: {
                EditButton()
            })
        }
    }
    // 並び替え処理と並び替え後の保存
    func replaceRow(_ from: IndexSet, _ to: Int) {
        quizzesArray.move(fromOffsets: from, toOffset: to) // 配列内での並び替え
        if let encodedArray = try? JSONEncoder().encode(quizzesArray) {
            quizzesArray = encodedArray

        }
    }

    func rowRemove(at offsets: IndexSet) {
        var array = quizzesArray
        array.remove(atOffsets: offsets)
        if let encodedArray = try? JSONEncoder().encode(array) {
            quizzesArray = encodedArray

        }
    }


    // 問題追加(保存)の関数
    func addQuiz(question: String, answer: String) {
        if question.isEmpty{
            print("プリント文が入力されていません")
            return
        }
        var savingAnswers = true //保存するためのtrue/falseを入れる変数

        //OかXかで,true/falseを切り替える
        switch answer {
        case "O":
            savingAnswers = true
        case "X":
            savingAnswers = false
        default:
            print("適切な答えが入ってません")
            break
        }

        let newQuiz = Quiz(question: question, answer: savingAnswers)

        var array = quizzesArray // 一時的に変数に入れておく
        array.append(newQuiz)//作った問題を配列に追加
        let storeKey = "quiz"//UserDefaultsに保存するためのキー

        //エンコードができたら保存
        if let encodedQuizzes = try? JSONEncoder().encode(array){
            UserDefaults.standard.setValue(encodedQuizzes, forKey: storeKey)
            questionText = ""//テキストフィードを空白に戻す
            quizzesArray = array // [既存問題 + 新問題]となった配列に更新

        }

    }
}

//#Preview {
//    CreateView()
//}
