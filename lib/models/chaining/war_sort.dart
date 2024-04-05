enum WarSortType {
  levelDes,
  levelAsc,
  respectDes,
  respectAsc,
  nameDes,
  nameAsc,
  colorAsc,
  colorDes,
  statsDes,
  statsAsc,
  onlineDes,
  onlineAsc,
  lifeDes,
  lifeAsc,
  notesDes,
  notesAsc,
  bounty,
}

class WarSort {
  WarSortType? type;
  late String description;

  WarSort({this.type}) {
    switch (type) {
      case WarSortType.levelDes:
        description = 'Sort by level (des)';
      case WarSortType.levelAsc:
        description = 'Sort by level (asc)';
      case WarSortType.respectDes:
        description = 'Sort by respect (des)';
      case WarSortType.respectAsc:
        description = 'Sort by respect (asc)';
      case WarSortType.nameDes:
        description = 'Sort by name (des)';
      case WarSortType.nameAsc:
        description = 'Sort by name (asc)';
      case WarSortType.colorDes:
        description = 'Sort by color (#-R-Y-G)';
      case WarSortType.colorAsc:
        description = 'Sort by color (G-Y-R-#)';
      case WarSortType.statsDes:
        description = 'Sort by stats (des)';
      case WarSortType.statsAsc:
        description = 'Sort by stats (asc)';
      case WarSortType.onlineDes:
        description = 'Sort online';
      case WarSortType.onlineAsc:
        description = 'Sort offline';
      case WarSortType.lifeDes:
        description = 'Sort by life (des)';
      case WarSortType.lifeAsc:
        description = 'Sort by life (asc)';
      case WarSortType.notesDes:
        description = 'Sort by note (des)';
      case WarSortType.notesAsc:
        description = 'Sort by note (asc)';
      case WarSortType.bounty:
        description = 'Sort by bounty amount';
      default:
        description = 'Sort by respect (des)';
        break;
    }
  }
}
