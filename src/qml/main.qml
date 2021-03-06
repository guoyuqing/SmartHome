import QtQuick 1.0
import "pad"
import "phone"

Item{
	property string devicetype: 'pad'
	width: devicetype == 'phone' ? 480 : 1024   //TODO
	height: devicetype == 'phone' ? 800 : 768 //TODO

	Loader {
		id: root
		source: rootPath()
		anchors.fill: parent
		z: 0
	}

	Item {
		anchors.fill: parent
		id: modalArea
		z: 1
	}

	/*
	Root{
		id: root
		anchors.fill: parent
	}
	*/

	function rootPath(){
		//check screensize etc
		 return devicetype == 'phone' ? "phone/RootPhone.qml" : "pad/RootPad.qml"
	}

}

