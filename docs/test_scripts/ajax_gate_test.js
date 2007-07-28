

var ajax_gate; // declare our gate variable here
var ajax_return; // declare our gate return here it will be set to 0 unless data has been returned
				 // if a request has been sent then it will be set to 0 until the data is returned
				 // to prevent old data being loaded by the caller

function openGate(url, req_type) {
	ajax_gate = false;
	ajax_return = 0;
	if (window.XMLHttpRequest) {
		try {
			ajax_gate = new XMLHttpRequest();
		} catch(e) {
			ajax_gate = false;
		}
	} else if (window.ActiveXObject) {
		try {
			ajax_gate = new ActiveXObject('Msxml2.XMLHTTP');
		} catch(e) {
			try {
				ajax_gate = new ActiveXObject('Microsoft.XMLHTTP');
			} catch(e){
				ajax_gate = false;
			}
		}
	} else {
		ajax_gate = false;
	}
	if(ajax_gate) {
			ajax_gate.onreadystatechange = GateTraffic(req_type);
			ajax_gate.open('GET', url, true);
			ajax_gate.send('');
	}
}

function GateTraffic(req_type) {
    
    if (ajax_gate.readyState == 4) {
        // only if 'OK'
        if (ajax_gate.status == 200) {
            // return the xml document
            if (req_type == 'xml') {
            	ajax_return = ajax_gate.responseXML;
            } else if (req_type == 'txt') {
            	ajax_return = ajax_gate.responseText;
            }            
        } else {
            alert('Failure retrieving the XML data:\n' +
                ajax_gate.statusText);
        }
    } else {
    	ajax_return = 0;
    }
}

function check_Gate() {
	while (ajax_return == 0) {
		return ajax_return;
	}
}
