import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // MyAppを起動
}

// アプリの全体を動かすWidget
class MyApp extends StatelessWidget {
  // super.key: 親クラスである StatelessWidget に Key を渡している。Flutterの差分描画に使われる
  const MyApp({super.key});

  @override
  // Flutterで全てのUIは build() メソッドの中で構築される
  // context は、親ウィジェットの情報やテーマへのアクセスに使う
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2D Gomoku', // アプリのタイトル
      home: const GomokuBoard(), // アプリ起動時に最初に表示する画面を指定
    );
  }
}

// 状態（盤面、ターン）を持つので、StatefulWidgetを使用
// State<GomokuBoard> が実際の状態管理とUI構築を行う
class GomokuBoard extends StatefulWidget {
  const GomokuBoard({super.key});

  @override
  State<GomokuBoard> createState() => _GomokuBoardState(); // このWidgetに対応するStateクラスを返す
}

// 最初にアンダーバーつけるとprivateなクラスになる
class _GomokuBoardState extends State<GomokuBoard> {
  static const int boardSize = 9; // 盤面のサイズ（9×9）
  List<List<String>> board = List.generate(boardSize, (_) => List.filled(boardSize, '')); // 盤面の状態（空文字''、'●'、'○'）を格納する2次元配列
  bool isBlackTurn = true; // 黒番か白番か（trueなら黒）

  // マスをタップしたときの処理
  void handleTap(int row, int col) {
    if (board[row][col] != '') return; // すでに置かれていたら無視

    // ● と ○ が交互に置かれるようになっている
    setState(() {
      board[row][col] = isBlackTurn ? '●' : '○';
      if (checkWin(row, col)) {
        // 勝利したら表示
        final winner = isBlackTurn ? '黒' : '白';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$winner の勝ち！')),
        );
      } else {
        isBlackTurn = !isBlackTurn;
      }
    });
  }

  bool checkWin(int row, int col) {
    final String currentStone = board[row][col];

    // 方向ごとにチェック（横, 縦, 斜め↘︎, 斜め↙︎）
    return checkDirection(row, col, 0, 1, currentStone) || // 横方向
          checkDirection(row, col, 1, 0, currentStone) || // 縦方向
          checkDirection(row, col, 1, 1, currentStone) || // 右下斜め ↘︎
          checkDirection(row, col, 1, -1, currentStone);  // 左下斜め ↙︎
  }

  // ある方向に何個連続しているか調べる（dirRow, dirColで方向を指定）
  bool checkDirection(int row, int col, int dirRow, int dirCol, String stone) {
    int count = 1;

    // 前方向
    for (int i = 1; i < 5; i++) {
      int newRow = row + dirRow * i;
      int newCol = col + dirCol * i;
      if (isInsideBoard(newRow, newCol) && board[newRow][newCol] == stone) {
        count++;
      } else {
        break;
      }
    }

    // 逆方向
    for (int i = 1; i < 5; i++) {
      int newRow = row - dirRow * i;
      int newCol = col - dirCol * i;
      if (isInsideBoard(newRow, newCol) && board[newRow][newCol] == stone) {
        count++;
      } else {
        break;
      }
    }

    return count >= 5;
  }

  // ボード内かどうかを判定
  bool isInsideBoard(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('五目並べ（2D）'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // MainAxisAlignment: ウィジェットの並び方（レイアウト）を制御するための定数の1つ
          children: List.generate(boardSize, (row) { // 盤面の表示（UI）
            // Column の中に Row を並べて盤面（2次元）を構築
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(boardSize, (col) {
                return GestureDetector( // GestureDetector: タップ・長押し・スワイプなどのユーザー操作（ジェスチャー）を検出するためのウィジェット
                  onTap: () => handleTap(row, col),
                  // 各マスは Container で表示され、タップ可能にするために GestureDetector で包んでいる
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.all(2), // EdgeInsets: 余白（padding や margin）を設定するためのクラス
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    alignment: Alignment.center,
                    child: Text( // 中には Text で '●' または '○' を表示
                      board[row][col],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
