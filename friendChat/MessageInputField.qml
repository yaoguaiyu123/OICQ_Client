import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components" as MyComponent
import CustomComponents

Rectangle {
    id: container
    height: 200
    Layout.fillWidth: true
    color: "#f2f2f2"
    signal send(string text)   //自定义信号

    Row{
        x: 8
        spacing: 8
        MyComponent.IconButton{
            width: 32
            height: 32
            imagePath: "qrc:/icon/biaoqing_black.png"
            hoveredImagePath: "qrc:/icon/biaoqing_blue.png"
        }
        MyComponent.IconButton{
            width: 32
            height: 32
            imagePath: "qrc:/icon/jiandao_black.png"
            hoveredImagePath: "qrc:/icon/jiandao_blue.png"
        }
        MyComponent.IconButton{
            width: 32
            height: 32
            imagePath: "qrc:/icon/wenjian_black.png"
            hoveredImagePath: "qrc:/icon/wenjian_blue.png"
        }
        MyComponent.IconButton{
            width: 32
            height: 32
            imagePath: "qrc:/icon/tupian_black.png"
            hoveredImagePath: "qrc:/icon/tupian_blue.png"
        }
    }

    ScrollView {
        id: view
        y: 32
        width: container.width - 20
        height: container.height - 32
        //数据缓冲的TextArea
        TextArea {
            id: hiddenArea
            textFormat: TextArea.MarkdownText
            visible: false
            z:-1
        }

        TextArea {
            id: area
            height: 200
            width: view.width
            color: "#0E0E0E"
            font.pixelSize: 14
            textFormat: TextArea.MarkdownText
            background: Rectangle {
                color: "#f2f2f2"
                radius: 4
            }
            verticalAlignment: TextArea.AlignTop
            wrapMode: TextArea.WrapAnywhere
            Keys.onPressed: (event) => {
                if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) &&
                    (event.modifiers & Qt.ShiftModifier)) {
                    area.insert(area.cursorPosition, "\n")
                    event.accepted = true
                    // 调整ScrollView的位置到当前光标位置
                    // var rect = area.cursorRectangle;  // TODO
                    //view.contentItem.y = rect.y + rect.height - view.height / 2;
                } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
                    if (area.text !== "") {
                        send(area.text) // 发出信号
                        area.text = ""
                        event.accepted = true
                    }
                } else if (event.modifiers === Qt.ControlModifier && event.key === Qt.Key_V) {
                    // 自定义粘贴逻辑
                    event.accepted = true
                    hiddenArea.paste()
                    documentHandler.parseMarkDown(hiddenArea.text)
                    hiddenArea.clear()
                    area.insert(area.cursorPosition, "\n")
                }
            }
            TextDocumentHandler {
                id: documentHandler
                textDocument: area.textDocument
                hideTextDocument: hiddenArea.textDocument
                cursorPosition: area.cursorPosition
            }
        }
    }


    Button{
        width: 95
        height: 24
        x: container.width - 115
        y: container.height - 45
        background: Rectangle{
            radius: 2
            color: "#0099ff"
        }
        contentItem: Text{
            text:"发送"
            color: "white"
            font.pixelSize: 15
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        onClicked: {
            if(area.text !== ""){
                send(area.text)    //发出信号
                area.text = ""
            }
        }

    }




}