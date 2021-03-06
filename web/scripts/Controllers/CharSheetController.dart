import "dart:html";
import "package:DollLibCorrect/DollRenderer.dart";
import "../navbar.dart";
import "../CharSheetLib.dart";
import 'dart:async';
import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Random.dart';
import 'package:LoaderLib/Loader.dart';
import 'package:RenderingLib/RendereringLib.dart';

CharSheet sheet;
void main() {
    loadNavbar();
    drawSheet();

}

Future<Null> drawSheet() async {
    String dataString = window.location.search;
    await Doll.loadFileData();
    Doll doll;
    if(dataString.isNotEmpty && getParameterByName("type",null)  != null) {
        doll = Doll.randomDollOfType(int.parse(getParameterByName("type",null))); //chop off leading ?


    }else if (dataString.isNotEmpty) {
        doll = Doll.loadSpecificDoll(dataString.substring(1)); //chop off leading ?
    }else {
        doll = Doll.randomDollOfType(new Random().pickFrom(Doll.allDollTypes));
    }
    sheet = new SylveonSheet(doll, null);
    await (sheet as SylveonSheet).setup();
    //sheet = new SylveonSheet(new MonsterPocketDoll());

    Element innerDiv  = new DivElement();
    innerDiv.className = "cardWithForm";
    await sheet.draw(innerDiv);
    innerDiv.append(sheet.makeForm());
    querySelector("#contents").append(innerDiv);
}