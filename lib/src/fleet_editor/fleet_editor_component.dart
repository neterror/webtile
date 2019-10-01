import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:webtile38/src/providers/datastore.dart';
import 'fleet_model.dart';

@Component(
    selector: 'fleet-editor',
    templateUrl: 'fleet_editor_component.html',
    styleUrls: [
      'fleet_editor_component.css'
    ],
    providers: [
      materialProviders
    ],
    directives: [
      coreDirectives,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialSelectItemComponent,
      MaterialButtonComponent,
      ModalComponent,
      MaterialDialogComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialInputComponent,
      materialInputDirectives,
      MaterialAutoSuggestInputComponent,
      AutoFocusDirective,
      MaterialYesNoButtonsComponent
    ])
class FleetEditorComponent implements OnDestroy {
  bool newGroupDlg = false;
  bool newVehicleDlg = false;
  final List<FleetGroup> fleet;
  DataStore _store;

  FleetEditorComponent(this._store) : fleet = _store.fleet {
    print("the new fleet is $fleet");
    selectedGroup = 0;
  }
  String inputLabel;
  String newItem;

  int selectedVehicle;
  int selectedGroup;

  void ngOnDestroy() {
    _store.save();
  }

  void onAddGroup() {
    newItem = "";
    newGroupDlg = true;
  }

  void onAddVehicle() {
    print("adding vehicle in ${fleet[selectedGroup].name}");
    newItem = "";
    newVehicleDlg = true;
  }

  void onGroupDlgFinish(bool accepted) {
    newGroupDlg = false;
    if (accepted) {
      fleet.add(FleetGroup(newItem));
      selectedGroup = fleet.length - 1;
    }
  }

  void onVehicleDlgFinish(bool accepted) {
    newVehicleDlg = false;
    fleet[selectedGroup].vehicles.add(newItem);
  }

  void onSelectedVehicle(int index) => selectedVehicle = index;
  void onSelectedGroup(int index) => selectedGroup = index;
  void removeVehicle(int index) =>
      fleet[selectedGroup].vehicles.removeAt(index);

  void removeGroup(int index) => fleet.removeAt(index);
}
