import QtQuick 1.0

Image {
	id: footer
	property string activePage: 'device'
	height: 125*SCALEFACTOR
	Image {
		source: "footerBg.png"
		height: 140*SCALEFACTOR
		fillMode: Image.TileHorizontally
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
	}

	Row {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: 123*SCALEFACTOR
		Item {
			width: parent.width/3
			height: parent.height
			BorderImage {
				id: deviceButtonBackground
				anchors.fill: parent
				source: "footerButtonActive.png"
				border {left: 20; top: 20; right: 20; bottom: 20 }
				opacity: 0
			}
			Image {
				id: deviceButton
				height: sourceSize.height*SCALEFACTOR
				smooth: true
				fillMode: Image.PreserveAspectFit
				anchors.centerIn: parent
				source: "footerIconDevices.png"
			}
			MouseArea {
				anchors.fill: parent
				onClicked: footer.activePage = 'device'
			}
		}
		Image {
			source: "menuButtonDivider.png"
			height: parent.height
			fillMode: Image.TileVertically
		}
		Item {
			width: parent.width/3
			height: parent.height
			BorderImage {
				id: sensorButtonBackground
				anchors.fill: parent
				source: "footerButtonActive.png"
				border {left: 20; top: 20; right: 20; bottom: 20 }
				opacity: 0
			}
			Image {
				id: sensorButton
				anchors.centerIn: parent
				height: sourceSize.height*SCALEFACTOR
				smooth: true
				fillMode: Image.PreserveAspectFit
				source: "footerIconSensors.png"
			}
			MouseArea {
				anchors.fill: parent
				onClicked: footer.activePage = 'sensor'
			}
		}
		Image {
			source: "menuButtonDivider.png"
			height: parent.height
			fillMode: Image.TileVertically
		}
		Item {
			width: parent.width/3
			height: parent.height
			BorderImage {
				id: settingsButtonBackground
				anchors.fill: parent
				source: "footerButtonActive.png"
				border {left: 20; top: 20; right: 20; bottom: 20 }
				opacity: 0
			}
			Image {
				id: settingsButton
				anchors.centerIn: parent
				height: sourceSize.height*SCALEFACTOR
				smooth: true
				fillMode: Image.PreserveAspectFit
				source: "footerIconSettings.png"
			}
			MouseArea {
				anchors.fill: parent
				onClicked: footer.activePage = 'settings'
			}
		}
	}

	states: [
		State {
			when: activePage == 'device'
			PropertyChanges { target: deviceButtonBackground; opacity: 1 }
			PropertyChanges { target: deviceButton; source: "footerIconDevicesActive.png" }
		},
		State {
			when: activePage == 'sensor'
			PropertyChanges { target: sensorButtonBackground; opacity: 1 }
			PropertyChanges { target: sensorButton; source: "footerIconSensorsActive.png" }
		},
		State {
			when: activePage == 'settings'
			PropertyChanges { target: settingsButtonBackground; opacity: 1 }
			PropertyChanges { target: settingsButton; source: "footerIconSettingsActive.png" }
		}
	]

	transitions: [
		Transition {
			NumberAnimation { properties: "opacity"; duration: 100 }
		}

	]
}
