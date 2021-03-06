import "dart:html";
import "package:DollLibCorrect/DollRenderer.dart";
import "../DollMakerTools.dart";
import "../navbar.dart";
import "dart:async";
import "BaseController.dart";


BaseController controller;


Future<Null> main() async {
    await Doll.loadFileData();

    print("Hello World");
    loadNavbar();
    Random rand = new Random();

    print("going to load doll");
    loadDoll();
}


void loadDoll() {
    print("loading doll");
    String dataString = window.location.search;
    print("dataSTring is $dataString");
    Doll doll;
    if(dataString.isNotEmpty && getParameterByName("type",null)  != null) {
        doll = Doll.randomDollOfType(int.parse(getParameterByName("type",null))); //chop off leading ?

    }else if (dataString.isNotEmpty) {
        doll = Doll.loadSpecificDoll(dataString.substring(1)); //chop off leading ?
    }

    //doing it this way ensures no incorrect sized canvas from a default doll.
    if(doll == null) doll =  Doll.randomDollOfType(1);
    CanvasElement canvas = new CanvasElement(width: doll.width, height: doll.height);
    canvas.style.backgroundColor = "#eeeeee";
    querySelector("#doll").append(canvas);
    if(doll is QueenDoll) {
        controller = new QueenController(doll, canvas);

    }else {
        controller = new TestController(doll, canvas);
    }

    //whether i loaded or not, it's time to draw.
    controller.setupForms();
    controller.drawDollCreator();
}



class TestController extends BaseController {
    TestController(Doll doll, CanvasElement canvas) : super(doll, canvas);

    @override
    void setupForms() {
        querySelector("#imageSize").appendHtml("Images should be ${doll.width} width by ${doll.height} height");
        querySelector("#randomize").onClick.listen((e) => randomizeDoll());
        querySelector("#randomizeColors").onClick.listen((e) => randomizeDollColors());
        querySelector("#randomizeNotColors").onClick.listen((e) => randomizeDollNotColors());


        Element layerControls = querySelector("#layerControls");
        Element colorControls = querySelector("#colorControls");
        for (SpriteLayer l in doll.renderingOrderLayers.reversed) {
            DollMakerTools.drawLoadButtonForSpriteLayer(this, layerControls, l, drawDollCreator);
            DollMakerTools.drawDropDownForSpriteLayer(this, layerControls, l, drawDollCreator);
        }
        DollMakerTools.drawColorPickersForPallete(colorControls, doll.palette, drawDollCreator);

        if (undo == null) {
            undo = new ButtonElement();
            undo.setInnerHtml("Undo");
            querySelector("#contents").append(undo);
            undo.onClick.listen((e) => undoFunction());
        }

        if (redo == null) {
            redo = new ButtonElement();
            redo.setInnerHtml("Redo");
            querySelector("#contents").append(redo);
            redo.onClick.listen((e) => redoFunction());
        }
    }
}

class KidController extends BaseController {
    KidController(Doll doll, CanvasElement canvas) : super(doll, canvas);

    @override
    void setupForms() {
        super.setupForms();
        Element samplePaletteControls = querySelector("#samplePaletteControls");
        DollMakerTools.drawSamplePalettes(samplePaletteControls, controller, drawDollCreator, doll);
    }
}



class QueenController extends BaseController {
    QueenController(Doll doll, CanvasElement canvas) : super(doll, canvas);

    @override
    Future<Null> drawDollCreator([bool inQueue = false]) async {
        DollMakerTools.syncColorPickersToSprite(doll.palette);
        drawLayerControls();
        print("Draw doll creator");
        Renderer.clearCanvas(canvas);
        DollRenderer.drawDoll(canvas, doll);
        TextAreaElement dataBox = querySelector("#shareableURL");
        dataBox.value = "${window.location.origin}${window.location.pathname}?${doll.toDataUrlPart()}";
        //don't add it to the queue if you're already messing around in it, dunkass. you'll never escape the loop.
        if (!inQueue) {
            actionQueue.add(doll.toDataBytesX());
            actionQueueIndex = actionQueue.length - 1;
        }
    }


    @override
    void randomizeDoll() {
        print("randomizing and redrawing");
        doll.randomize();
        drawDollCreator();
    }

    @override
    void randomizeDollNotColors() {
        print("randomizing and redrawing");
        doll.randomizeNotColors();
        //can't do it in regular draw part cuz onChange is a bitch.
        DollMakerTools.syncColorPickersToSprite(doll.palette);
        drawDollCreator();
        drawLayerControls();
    }


    @override
    void setupForms() {
        querySelector("#randomize").onClick.listen((e) => randomizeDoll());
        querySelector("#randomizeColors").onClick.listen((e) => randomizeDollColors());
        querySelector("#randomizeNotColors").onClick.listen((e) => randomizeDollNotColors());


        Element colorControls = querySelector("#colorControls");

        drawLayerControls();
        DollMakerTools.drawColorPickersForPallete(colorControls, doll.palette, drawDollCreator);

        if (undo == null) {
            undo = new ButtonElement();
            undo.setInnerHtml("Undo");
            querySelector("#contents").append(undo);
            undo.onClick.listen((e) => undoFunction());
        }

        if (redo == null) {
            redo = new ButtonElement();
            redo.setInnerHtml("Redo");
            querySelector("#contents").append(redo);
            redo.onClick.listen((e) => redoFunction());
        }
    }

    void drawLayerControls() {
        Element layerControls = querySelector("#layerControls");
        layerControls.setInnerHtml("");
        for (SpriteLayer l in doll.renderingOrderLayers.reversed) {
            DollMakerTools.drawDropDownForSpriteLayer(controller, layerControls, l, drawDollCreator);
            print("gonna draw loader");
            DollMakerTools.drawLoadButtonForSpriteLayer(controller, layerControls, l, drawDollCreator);
        }


        //want to be able to add new layers
        DollMakerTools.addNewNamedLayerButton(controller, layerControls, drawDollCreator);
    }
}


