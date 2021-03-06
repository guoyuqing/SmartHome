import Qt 4.7
import ".."
import "../mainscripts.js" as MainScripts
import "VisualDeviceList.js" as VisualDeviceList

Item {
	id: visualDevice
	height: type == MainScripts.SENSOR ? MainScripts.VISUALDEVICEHEIGHT : action == "slider" ? slider.height : statusImg. height
	width: type == MainScripts.SENSOR ? MainScripts.VISUALSENSORWIDTH : action == "slider" ? slider.width : statusImg.width

	Rectangle{
		anchors.fill: parent
		color: 'green'
		visible: type == MainScripts.SENSOR
	}

	Image{
		id: statusImgDimBack
		source: action == "dim" ? "../off.png" : "../state_2.png"
		visible: type == MainScripts.DEVICE && action == ''
	}
	Image{
		id: statusImg
		source: statusImage()
		visible: type == MainScripts.DEVICE && action != "slider"
		opacity: action == "dim" ? parseInt(actionvalue, 10)/255+0.1 : action == '' ? (deviceState == MainScripts.METHOD_DIM ? deviceStateValue/255 + 0.1 : 1) : 1
	}

	Slider{
		id: slider
		visible: action == "slider"
		width: MainScripts.SLIDERWIDTH
		height: MainScripts.SLIDERHEIGHT

		onSlided: {
			console.log("DIMMED to " + dimvalue);
			device.dim(dimvalue);
		}

		Item {
			//This is a pseudo-item only for listening for changes in the model data
			property int state: device == undefined || device.state == undefined ? 0 : device.state
			onStateChanged: {
				if (state == MainScripts.METHOD_TURNON) {
					slider.value = slider.maximum;
				} else if (state == MainScripts.METHOD_TURNOFF) {
					slider.value = slider.minimum;
				}
			}
			property string stateValue:  device == undefined || device.stateValue == undefined ? 0 : device.stateValue
			onStateValueChanged: {
				if (state == MainScripts.METHOD_DIM) {
					slider.value = parseInt(stateValue, 10);
				}
			}
		}
	}

	z: selectedVisualDevice == visualDeviceId ? (infoBubble.open || visualDeviceMenu.open ? 160 : 150) : 5

	property string action: ''
	property string actionvalue: ''
	property int deviceId: 0
	property int visualDeviceId: 0
	property variant device: undefined
	property string deviceName: device == undefined ? '' : device.name
	property int deviceMethods: device == undefined || type != MainScripts.DEVICE ? 0 : device.methods
	property int deviceState: device == undefined || type != MainScripts.DEVICE ? 0 : device.state
	property string deviceStateValue: device == undefined || type != MainScripts.DEVICE ? '' : device.stateValue
	property bool expanded: false
	property int tabId: 1 //TODO
	property int type
	property int rotationAngle: (visualDevice.x - infoBubble.width/2)/2 * -1
	property bool hasHumidity: device == undefined || type != MainScripts.SENSOR ? false : device.hasHumidity
	property bool hasTemperature: device == undefined || type != MainScripts.SENSOR ? false : device.hasTemperature
	property string humidity: device == undefined || type != MainScripts.SENSOR ? '' : device.humidity
	property string temperature: device == undefined || type != MainScripts.SENSOR ? '' : device.temperature
	property string lastUpdated: device == undefined || type != MainScripts.SENSOR ? '' : device.lastUpdated

	Text{

		anchors.centerIn: parent
		text: shortSensorText()

		visible: type == MainScripts.SENSOR

		function shortSensorText(){
			var shortString = "";
			if(hasHumidity){
				shortString = humidity + ' %';
			}
			if(hasHumidity && hasTemperature){
				shortString = shortString + ', '
			}
			if(hasTemperature){
				shortString = shortString + temperature + ' C';
			}
			return shortString;
		}
	}

	MouseArea {
		property int movedX: 0
		property int movedY: 0
		anchors.fill: parent
		enabled: editable || visualDevice.action != 'slider'

		drag.target: editable ? visualDevice : undefined
		drag.axis: Drag.XandYAxis
		drag.minimumX: 0
		drag.maximumX: favoriteLayout.width - visualDevice.width - MainScripts.TOOLBARWIDTH
		drag.minimumY: 0
		drag.maximumY: favoriteLayout.height - visualDevice.height
		onPressed: {
			favoriteLayout.selectedVisualDevice = visualDeviceId
			movedX = visualDevice.x
			movedY = visualDevice.y
		}

		onClicked: {
			if(visualDevice.action != 0){
				console.log("TODO bekräftande meddelande, liten popup eller så");
				if(visualDevice.action == "on"){ //MainScripts.METHOD_TURNON
					device.turnOn();
				}
				else if(visualDevice.action == "off"){
					device.turnOff();
				}
				else if(visualDevice.action == "bell"){
					device.bell();
				}
				else if(visualDevice.action == "dim"){
					device.dim(visualDevice.actionvalue/100*255);
				}
				else if(visualDevice.action == "toggle"){
					//TODO change icon somewhat depending on current state?
					if(device.state == MainScripts.METHOD_TURNOFF){
						device.turnOn();
					}
					else{
						device.turnOff();
					}
				}

				return;
			}

			infoBubble.toggle();
			VisualDeviceList.visualDevicelist.visualDevice(visualDevice.visualDeviceId).expand(infoBubble.open);
		}
		onReleased: {
			if(editable && movedX != visualDevice.x || movedY != visualDevice.y){
				VisualDeviceList.visualDevicelist.visualDevice(visualDevice.visualDeviceId).layoutPosition(visualDevice.x, visualDevice.y, tabId);
			}
		}
		onPressAndHold: {
			if(editable){
				visualDeviceMenu.show()
			}
		}
	}

	DefaultMenu{
		id: visualDeviceMenu

		Component{
			id: footer

			Slider{
				id: actionvalueSlider
				width: parent.parent.width
				height: MainScripts.SLIDERHEIGHT
				visible: MainScripts.methodContains(deviceMethods, "dim")
				value: parseInt(visualDevice.actionvalue, 10)
				onSlided: {
					visualDevice.actionvalue = dimvalue;
					VisualDeviceList.visualDevicelist.visualDevice(visualDevice.visualDeviceId).updateActionValue(dimvalue);
				}
			}
		}

		headerText: visualDevice.deviceName

		model: ListModel{
			ListElement{
				text: "Remove from layout"
				optionValue: 'removefromlayout'
			}
		}
		footerComponent: visualDevice.action == "dim" ? footer : undefined

		onOptionSelected: {
			if(value == "removefromlayout"){
				visualDevice.destroy();
				VisualDeviceList.visualDevicelist.visualDevice(visualDevice.visualDeviceId).deleteDevice();
			}
		}
	}

	Popup{
		id: infoBubble
		//assignTo: visualDevice
		open: visualDevice.expanded

		Component{
			id: infoSensorComp
			Item {
				id: infoSensor
				height: childrenRect.height
				width: childrenRect.width
				z: 3

				Column{
					Text{
						color: "white"
						text: deviceName
					}
					Text{
						color: "white"
						text: "Temperature: " + temperature + " C"
						visible: hasTemperature
					}
					Text{
						color: "white"
						text: "Humidity: " + humidity + " %"
						visible: hasHumidity
					}
					Text{
						color: "white"
						text: "Last updated: " + lastUpdated
						visible: lastUpdated != ''
					}
				}
			}
		}

		Component {
			id: infoDeviceComp
			Item {
				height: childrenRect.height
				width: childrenRect.width

				Column{
					Text{
						text: deviceName
						color: 'white'
					}

					Text{
						text: "Next run time: " + (device == undefined ? 'undef' : Qt.formatDateTime(device.nextRunTime))
						color: 'white'
						visible: device != undefined && device.nextRunTime != 'Invalid Date' //TODO
					}

					Row{
						id: buttonrow
						anchors.horizontalCenter: parent.horizontalCenter
						ActionButton{
							text: "OFF"
							visible: MainScripts.methodContains(deviceMethods, "off")
							onClicked: {
								console.log("CLICKED off");
								device.turnOff();
							}
						}

						ActionButton{
							text: "ON"
							visible: MainScripts.methodContains(deviceMethods, "on")
							onClicked: {
								console.log("CLICKED on");
								device.turnOn();
							}
						}

						ActionButton{
							text: "BELL"
							visible: MainScripts.methodContains(deviceMethods, "bell")
							onClicked: {
								console.log("CLICKED BELL");
								device.bell();
							}
						}
					}

					Slider{
						id: slider
						width: parent.width
						height: MainScripts.SLIDERHEIGHT
						visible: MainScripts.methodContains(deviceMethods, "dim")
						onSlided: {
							console.log("DIMMED to " + dimvalue);
							device.dim(dimvalue);
						}

						Item {
							//This is a pseudo-item only for listening for changes in the model data
							property int state: deviceState
							onStateChanged: {
								if (state == MainScripts.METHOD_TURNON) {
									slider.value = slider.maximum;
								} else if (state == MainScripts.METHOD_TURNOFF) {
									slider.value = slider.minimum;
								}
							}
							property string stateValue: deviceStateValue
							onStateValueChanged: {
								if (state == MainScripts.METHOD_DIM) {
									slider.value = parseInt(stateValue, 10);
								}
							}
						}
					}
				}
			}
		}

		content: type == MainScripts.SENSOR ? infoSensorComp : infoDeviceComp
	}

	function statusImage(){
		if(action == 'on'){
			return "../on.png";
		}
		if(action == 'off'){
			return "../off.png";
		}
		if(action == 'bell'){
			return "../bell.png";
		}
		if(action == 'dim'){
			return "../on.png";
		}
		if(action == 'toggle'){
			return "../toggle.png";
		}

		if(deviceState == MainScripts.METHOD_TURNON){
			return "../state_1.png";
		}
		if(deviceState == MainScripts.METHOD_DIM){
			return "../state_1.png"; //TODO
		}
		if(type == MainScripts.SENSOR){
			//return "green"; //TODO
		}

		return "../state_2.png";
	}
}
