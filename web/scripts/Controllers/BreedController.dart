import "dart:html";
import "../navbar.dart";
import "dart:async";
import 'package:DollLibCorrect/DollRenderer.dart';

Element container;

Doll doll1;
Doll doll2;
Doll child;
Random rand = new Random();

CanvasElement canvas1;
CanvasElement canvas2;


Future<Null> main() async{
    loadNavbar();
    await Loader.preloadManifest();
    container = querySelector("#contents");
    container.text = "testing";
    todo("draw two dolls");
    todo("draw two text area inputs");
    todo("draw drop down of and/or/breed");
    todo("draw combine button");
    todo("output single canvas of parents + operation +  result");
    todo("can output as many as you want");
    initParents();
    drawParents();
    makeBreedButtons();
}

void initParents() {
    doll1 = Doll.randomDollOfType(rand.pickFrom(Doll.allDollTypes));
    if(rand.nextBool()) {
        doll2 = Doll.randomDollOfType(rand.pickFrom(Doll.allDollTypes));
    }else {
        doll2 = Doll.randomDollOfType(doll1.renderingType);
    }
}

void drawParents() {
    drawOneParent(doll1);
    drawOneParent(doll2);
}

void drawOneParent(Doll parent) {
    DivElement div = new DivElement();
    div.classes.add("breedingParent");
    CanvasElement parentCanvas = new CanvasElement(width: parent.width, height: parent.height);
    parentCanvas.style.border = "3px solid #000000";

    ButtonElement loadButton = new ButtonElement()..text = "Load";

    TextAreaElement dataBox = new TextAreaElement();
    dataBox.style.display = "block";
    dataBox.value = "${parent.toDataBytesX()}";
    loadButton.onClick.listen((Event e) {
        Renderer.clearCanvas(parentCanvas);
        parent = Doll.loadSpecificDoll(dataBox.value);
        parentCanvas.width = parent.width;
        parentCanvas.height = parent.height;

        DollRenderer.drawDoll(parentCanvas, parent);
    });

    div.append(parentCanvas);
    div.append(dataBox);
    div.append(loadButton);
    container.append(div);

    DollRenderer.drawDoll(parentCanvas, parent);
}

void makeBreedButtons() {
    ButtonElement and = new ButtonElement()..text = "Combine with AND Alchemy";
    ButtonElement or = new ButtonElement()..text = "Combine with OR Alchemy";
    ButtonElement breed = new ButtonElement()..text = "Combine the Old Fashioned Way";
    container.append(and);
    container.append(or);
    container.append(breed);

    and.onClick.listen((Event e) {
        child = Doll.andAlchemizeDolls(<Doll>[doll1, doll2]);
        drawResult();
    });

    or.onClick.listen((Event e) {
        child = Doll.orAlchemizeDolls(<Doll>[doll1, doll2]);
        drawResult();
    });

    breed.onClick.listen((Event e) {
        child = Doll.breedDolls(<Doll>[doll1, doll2]);
        drawResult();
    });
}

Future<Null> drawResult() async {
    CanvasElement result = new CanvasElement(width: 1200, height: 300);
    container.append(result);

    CanvasElement one = await drawDoll(doll1, 400,300);
    CanvasElement two = await drawDoll(doll2, 400,300);
    CanvasElement three = await drawDoll(child, 400,300);
    result.context2D.drawImage(one, 0, 0);
    result.context2D.drawImage(two, 400, 0);
    result.context2D.drawImage(three, 800, 0);
}

Future<CanvasElement>  drawDoll(Doll doll, int w, int h) async {
        CanvasElement ret = new CanvasElement(width: w, height: h);
        CanvasElement dollCanvas = new CanvasElement(width: doll.width, height: doll.height);
        await DollRenderer.drawDoll(dollCanvas, doll);
        dollCanvas = Renderer.cropToVisible(dollCanvas);
        Renderer.drawToFitCentered(ret, dollCanvas);
        return ret;
}

void todo(String todo) {
    LIElement tmp = new LIElement();
    tmp.setInnerHtml("TODO: $todo");
    container.append(tmp);
}
