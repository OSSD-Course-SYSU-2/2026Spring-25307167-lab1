@Entry
@Component
struct Index {
  // 游戏配置
  private readonly ROWS: number = 20;
  private readonly COLS: number = 10;
  private readonly BLOCK_SIZE: number = 30;

  // 游戏状态
  @State gameBoard: number[][] = [];
  @State currentPiece: number[][] = [];
  @State currentX: number = 0;
  @State currentY: number = 0;
  @State currentType: number = 0;
  @State score: number = 0;
  @State isGameOver: boolean = false;
  @State isPaused: boolean = false;

  // 方块类型定义（7种经典方块，每种方块包含多个旋转状态）
  private readonly PIECES: number[][][][] = [
    // I型 - 4个旋转状态
    [
      [[1, 1, 1, 1]],
      [[1], [1], [1], [1]],
      [[1, 1, 1, 1]],
      [[1], [1], [1], [1]]
    ],
    // O型 - 1个旋转状态（正方形旋转不变）
    [
      [[1, 1], [1, 1]]
    ],
    // T型 - 4个旋转状态
    [
      [[0, 1, 0], [1, 1, 1]],
      [[1, 0], [1, 1], [1, 0]],
      [[1, 1, 1], [0, 1, 0]],
      [[0, 1], [1, 1], [0, 1]]
    ],
    // L型 - 4个旋转状态
    [
      [[1, 0], [1, 0], [1, 1]],
      [[1, 1, 1], [1, 0, 0]],
      [[1, 1], [0, 1], [0, 1]],
      [[0, 0, 1], [1, 1, 1]]
    ],
    // J型 - 4个旋转状态
    [
      [[0, 1], [0, 1], [1, 1]],
      [[1, 0, 0], [1, 1, 1]],
      [[1, 1], [1, 0], [1, 0]],
      [[1, 1, 1], [0, 0, 1]]
    ],
    // S型 - 2个旋转状态
    [
      [[0, 1, 1], [1, 1, 0]],
      [[1, 0], [1, 1], [0, 1]]
    ],
    // Z型 - 2个旋转状态
    [
      [[1, 1, 0], [0, 1, 1]],
      [[0, 1], [1, 1], [1, 0]]
    ]
  ];

  // 当前旋转状态
  @State currentRotation: number = 0;

  // 方块颜色
  private readonly COLORS: string[] = [
    '#00FFFF', // I - 青色
    '#FFFF00', // O - 黄色
    '#800080', // T - 紫色
    '#FFA500', // L - 橙色
    '#0000FF', // J - 蓝色
    '#00FF00', // S - 绿色
    '#FF0000'  // Z - 红色
  ];

  aboutToAppear() {
    this.initGame();
  }

  // 初始化游戏
  initGame() {
    // 初始化游戏板
    this.gameBoard = [];
    for (let i = 0; i < this.ROWS; i++) {
      let row: number[] = [];
      for (let j = 0; j < this.COLS; j++) {
        row.push(0);
      }
      this.gameBoard.push(row);
    }
    this.score = 0;
    this.isGameOver = false;
    this.isPaused = false;
    this.spawnPiece();
  }

  // 生成新方块
  spawnPiece() {
    this.currentType = Math.floor(Math.random() * 7);
    this.currentRotation = 0;
    this.currentPiece = this.copyPiece(this.PIECES[this.currentType][this.currentRotation]);
    this.currentX = Math.floor((this.COLS - this.currentPiece[0].length) / 2);
    this.currentY = 0;

    if (!this.isValidPosition(this.currentX, this.currentY, this.currentPiece)) {
      this.isGameOver = true;
    }
  }

  // 深拷贝方块
  copyPiece(piece: number[][]): number[][] {
    let result: number[][] = [];
    for (let i = 0; i < piece.length; i++) {
      let row: number[] = [];
      for (let j = 0; j < piece[i].length; j++) {
        row.push(piece[i][j]);
      }
      result.push(row);
    }
    return result;
  }

  // 检查位置是否有效
  isValidPosition(x: number, y: number, piece: number[][]): boolean {
    for (let row = 0; row < piece.length; row++) {
      for (let col = 0; col < piece[row].length; col++) {
        if (piece[row][col] !== 0) {
          let newX = x + col;
          let newY = y + row;

          if (newX < 0 || newX >= this.COLS || newY >= this.ROWS) {
            return false;
          }

          if (newY >= 0 && this.gameBoard[newY][newX] !== 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // 移动方块
  movePiece(dx: number, dy: number): boolean {
    if (this.isValidPosition(this.currentX + dx, this.currentY + dy, this.currentPiece)) {
      this.currentX += dx;
      this.currentY += dy;
      return true;
    }
    return false;
  }

  // 旋转方块
  rotatePiece() {
    let maxRotations = this.PIECES[this.currentType].length;
    let newRotation = (this.currentRotation + 1) % maxRotations;
    let rotated = this.copyPiece(this.PIECES[this.currentType][newRotation]);

    if (this.isValidPosition(this.currentX, this.currentY, rotated)) {
      this.currentRotation = newRotation;
      this.currentPiece = rotated;
    }
  }

  // 固定方块到游戏板
  lockPiece() {
    for (let row = 0; row < this.currentPiece.length; row++) {
      for (let col = 0; col < this.currentPiece[row].length; col++) {
        if (this.currentPiece[row][col] !== 0) {
          let boardY = this.currentY + row;
          let boardX = this.currentX + col;
          if (boardY >= 0 && boardY < this.ROWS && boardX >= 0 && boardX < this.COLS) {
            this.gameBoard[boardY][boardX] = this.currentType + 1;
          }
        }
      }
    }
    this.clearLines();
    this.spawnPiece();
  }

  // 消除完整行
  clearLines() {
    let linesCleared = 0;
    for (let row = this.ROWS - 1; row >= 0; row--) {
      let isFull = true;
      for (let col = 0; col < this.COLS; col++) {
        if (this.gameBoard[row][col] === 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        this.gameBoard.splice(row, 1);
        let newRow: number[] = [];
        for (let j = 0; j < this.COLS; j++) {
          newRow.push(0);
        }
        this.gameBoard.unshift(newRow);
        linesCleared++;
        row++;
      }
    }
    if (linesCleared > 0) {
      this.score += linesCleared * 100 * linesCleared;
    }
  }

  // 下落
  drop() {
    if (this.isGameOver || this.isPaused) return;

    if (!this.movePiece(0, 1)) {
      this.lockPiece();
    }
  }

  // 快速下落
  hardDrop() {
    while (this.movePiece(0, 1)) {}
    this.lockPiece();
  }

  // 获取显示的游戏板（包含当前方块）
  getDisplayBoard(): number[][] {
    let display: number[][] = this.copyPiece(this.gameBoard);

    for (let row = 0; row < this.currentPiece.length; row++) {
      for (let col = 0; col < this.currentPiece[row].length; col++) {
        if (this.currentPiece[row][col] !== 0) {
          let boardY = this.currentY + row;
          let boardX = this.currentX + col;
          if (boardY >= 0 && boardY < this.ROWS && boardX >= 0 && boardX < this.COLS) {
            display[boardY][boardX] = this.currentType + 1;
          }
        }
      }
    }
    return display;
  }

  // 渲染游戏格子
  @Builder
  renderCell(cell: number) {
    Row()
      .width(this.BLOCK_SIZE)
      .height(this.BLOCK_SIZE)
      .backgroundColor(cell === 0 ? '#0f0f23' : this.COLORS[cell - 1])
      .border({
        width: 1,
        color: cell === 0 ? '#1a1a3e' : '#FFFFFF',
        radius: 2
      })
      .margin({ left: 0.5, right: 0.5, top: 0.5, bottom: 0.5 })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('俄罗斯方块')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(60)
      .backgroundColor('#1a1a2e')
      .justifyContent(FlexAlign.Center)

      // 游戏信息栏
      Row() {
        Text('分数: ' + this.score)
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(50)
      .backgroundColor('#16213e')
      .justifyContent(FlexAlign.Center)

      // 游戏区域
      Stack() {
        // 游戏背景
        Column() {
          ForEach(this.getDisplayBoard(), (row: number[], rowIndex: number) => {
            Row() {
              ForEach(row, (cell: number) => {
                this.renderCell(cell)
              })
            }
          })
        }
        .padding(5)
        .backgroundColor('#0a0a1a')
        .border({ width: 3, color: '#4a4a6a', radius: 5 })

        // 游戏结束遮罩
        if (this.isGameOver) {
          Column() {
            Text('游戏结束')
              .fontSize(32)
              .fontColor('#FF0000')
              .fontWeight(FontWeight.Bold)
            Text('最终分数: ' + this.score)
              .fontSize(24)
              .fontColor('#FFFFFF')
              .margin({ top: 20 })
            Button('重新开始')
              .fontSize(20)
              .backgroundColor('#4CAF50')
              .margin({ top: 30 })
              .onClick(() => {
                this.initGame();
              })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .justifyContent(FlexAlign.Center)
        }

        // 暂停遮罩
        if (this.isPaused && !this.isGameOver) {
          Column() {
            Text('游戏暂停')
              .fontSize(32)
              .fontColor('#FFFF00')
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({ top: 20 })

      // 控制按钮区域
      Column() {
        // 方向控制
        Row() {
          Button('←')
            .fontSize(28)
            .width(70)
            .height(70)
            .backgroundColor('#3498db')
            .onClick(() => {
              if (!this.isGameOver && !this.isPaused) {
                this.movePiece(-1, 0);
              }
            })

          Column() {
            Button('↑')
              .fontSize(28)
              .width(70)
              .height(50)
              .backgroundColor('#9b59b6')
              .onClick(() => {
                if (!this.isGameOver && !this.isPaused) {
                  this.rotatePiece();
                }
              })

            Button('↓')
              .fontSize(28)
              .width(70)
              .height(50)
              .backgroundColor('#e67e22')
              .onClick(() => {
                this.drop();
              })
          }
          .margin({ left: 20, right: 20 })

          Button('→')
            .fontSize(28)
            .width(70)
            .height(70)
            .backgroundColor('#3498db')
            .onClick(() => {
              if (!this.isGameOver && !this.isPaused) {
                this.movePiece(1, 0);
              }
            })
        }
        .margin({ top: 20 })

        // 功能按钮
        Row() {
          Button('快速下落')
            .fontSize(18)
            .width(120)
            .height(50)
            .backgroundColor('#e74c3c')
            .onClick(() => {
              if (!this.isGameOver && !this.isPaused) {
                this.hardDrop();
              }
            })

          Button(this.isPaused ? '继续' : '暂停')
            .fontSize(18)
            .width(120)
            .height(50)
            .backgroundColor('#f39c12')
            .margin({ left: 20 })
            .onClick(() => {
              if (!this.isGameOver) {
                this.isPaused = !this.isPaused;
              }
            })

          Button('重新开始')
            .fontSize(18)
            .width(120)
            .height(50)
            .backgroundColor('#27ae60')
            .margin({ left: 20 })
            .onClick(() => {
              this.initGame();
            })
        }
        .margin({ top: 20 })
      }
      .width('100%')
      .padding({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0f0f23')
  }
}
