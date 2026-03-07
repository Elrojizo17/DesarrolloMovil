import 'constants.dart';

class GameMap {
  static const List<List<int>> originalLayout = [
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    [1,2,2,2,2,2,2,1,2,2,2,2,2,2,1],
    [1,2,1,1,2,1,2,1,2,1,2,1,1,2,1],
    [1,3,1,2,2,2,2,2,2,2,2,2,1,3,1],
    [1,2,1,1,2,1,1,1,1,1,2,1,1,2,1],
    [1,2,2,2,2,2,2,1,2,2,2,2,2,2,1],
    [1,2,1,1,2,1,2,1,2,1,2,1,1,2,1],
    [1,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  ];

  static late List<List<int>> layout;

  static void resetMap() {
    layout = originalLayout.map((row) => List<int>.from(row)).toList();
  }

  static bool isWall(int x, int y) {
    if (x < 0 || x >= kMapWidth || y < 0 || y >= kMapHeight) return true;
    return layout[y][x] == 1;
  }
}