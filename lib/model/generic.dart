abstract class Searchable {
  String getItemName();
}

abstract class Selectable {
  bool isSelected();
}

class SelectableImpl implements Selectable {
  bool _isSelected;

  SelectableImpl(this._isSelected);

  SelectableImpl.copy(this._isSelected);

  @override
  bool isSelected() => _isSelected;
}
