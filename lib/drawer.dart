import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:trust_rig_version_one/scan_page.dart';
import 'package:trust_rig_version_one/send_data.dart';

class CustomDrawer extends StatefulWidget {
  final BluetoothDevice device;
  final List<BluetoothService> services;
  const CustomDrawer({Key? key, required this.device, required this.services})
      : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  // Static string to display connection state
  static String stateText = 'Connecting';
  // Storing the current connection state
  BluetoothConnectionState deviceState = BluetoothConnectionState.disconnected;
  // Handle for the connection state listener to be removed when the screen is disposed
  StreamSubscription<BluetoothConnectionState>? _stateListener;

  TextEditingController textFieldController = TextEditingController();
  String data = '';
  // Connect button text
  String connectButtonText = 'Disconnect';
  //
  Map<String, List<int>> notifyDatas = {};
  List<BluetoothService> bluetoothService = [];

  @override
  void initState() {
    super.initState();
    // Start the connection
    connect();
    // Register the state connection listener
    _stateListener = widget.device.state.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // Ignore if the state is the same
        return;
      }
      // Update the connection state information
      setBleConnectionState(event);
    });
  }

  @override
  void dispose() {
    // Release the state listener
    _stateListener?.cancel();
    // Disconnect
    disconnect();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      // Only update when the screen is mounted
      super.setState(fn);
    }
  }

  /* Update the connection state */
  setBleConnectionState(BluetoothConnectionState event) {
    switch (event) {
      case BluetoothConnectionState.disconnected:
        stateText = 'Disconnected';
        // Change button state
        connectButtonText = 'Connect';
        break;
      case BluetoothConnectionState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothConnectionState.connected:
        stateText = 'Connected';
        // Change button state
        connectButtonText = 'Disconnect';
        break;
      case BluetoothConnectionState.connecting:
        stateText = 'Connecting';
        break;
    }
    // Save the previous state event
    deviceState = event;
    setState(() {});
  }

  /* Start the connection */
  Future<bool> connect() async {
    setState(() {
      /* Change the status display to Connecting */
      stateText = 'Connecting';
    });

    /*
        Set the timeout to 15 seconds (15000ms) and disable auto-connect
        Note: autoconnect delays the connection in some cases.
       */
    try {
      await widget.device
          .connect(autoConnect: false)
          .timeout(Duration(milliseconds: 15000), onTimeout: () {
        // Timeout occurred
        debugPrint('timeout failed');

        // Change the connection state to disconnected
        setBleConnectionState(BluetoothConnectionState.disconnected);
      });

      List<BluetoothService> bleServices =
          await widget.device.discoverServices();
      setState(() {
        bluetoothService = bleServices;
      });
      // Print each characteristic to the debug console
      for (BluetoothService service in bleServices) {
        print('============================================');
        print('Service UUID: ${service.uuid}');
        for (BluetoothCharacteristic c in service.characteristics) {
          print('\tcharacteristic UUID: ${c.uuid.toString()}');
          print('\t\twrite: ${c.properties.write}');
          print('\t\tread: ${c.properties.read}');
          print('\t\tnotify: ${c.properties.notify}');
          print('\t\tisNotifying: ${c.isNotifying}');
          print(
              '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
          print('\t\tindicate: ${c.properties.indicate}');

          // If notify or indicate is true, it means the characteristic can receive data from the device, so enable it
          // However, if there are no descriptors, notify cannot be set, so skip it!
          if (c.properties.notify && c.descriptors.isNotEmpty) {
            // Check if the descriptor with the UUID 0x2902 exists
            for (BluetoothDescriptor d in c.descriptors) {
              print('BluetoothDescriptor uuid ${d.uuid}');

              print('d.lastValue: ${d.lastValue}');
            }

            // If notify is not already set...
            if (!c.isNotifying) {
              try {
                await c.setNotifyValue(true);
                // Create a Map key to store received data
                notifyDatas[c.uuid.toString()] = List.empty();
                c.value.listen((value) {
                  // Data read processing!
                  print('${c.uuid}: $value');
                  setState(() {
                    // Store received data for display on the screen
                    notifyDatas[c.uuid.toString()] = value;
                  });
                });

                // Add a delay after setting the notify to avoid issues
                await Future.delayed(const Duration(milliseconds: 500));
              } catch (e) {
                print('error ${c.uuid} $e');
              }
            }
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint('connection failed $e');
      return false;
    }
  }

  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      widget.device.disconnect();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController customStringController = TextEditingController();
    final double screenHeight = MediaQuery.of(context).size.height;

    String buttonText;
    Color buttonColor;
    Color textColor = Theme.of(context).colorScheme.primary;
    switch (deviceState) {
      case BluetoothConnectionState.connected:
        buttonText = 'Disconnect';
        buttonColor = Theme.of(context).colorScheme.tertiary;
        textColor = Theme.of(context).colorScheme.secondary;
        break;
      case BluetoothConnectionState.disconnected:
        buttonText = 'Connect';
        buttonColor = Theme.of(context).colorScheme.secondary;
        textColor = Theme.of(context).colorScheme.secondary;
        break;
      default:
        buttonText = 'Connecting';
        buttonColor = Theme.of(context).colorScheme.secondary;
        break;
    }

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  widget.device.localName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            // Connection state and Connect/Disconnect button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '$stateText',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      if (deviceState == BluetoothConnectionState.connected) {
                        /* If connected, disconnect */
                        disconnect();
                      } else if (deviceState ==
                          BluetoothConnectionState.disconnected) {
                        /* If disconnected, connect */
                        connect();
                      }
                    },
                    child: Text(
                      connectButtonText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.background.withOpacity(0.7),
                ),
              ),
              onPressed: () {
                // This button is to refresh the connection
                connect();
              },
              child: Text(
                'Refresh',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.background.withOpacity(0.7),
                  ),
                ),
                onPressed: () async {
                  widget.device.disconnect();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ScanPage()));
                },
                child: Text(
                  'Choose another device',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )),

            TextFormField(
              decoration: InputDecoration(
                labelText: 'Send data to device',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              controller: textFieldController,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.background.withOpacity(0.7),
                ),
              ),
              onPressed: () {
                String customString = textFieldController.text;
                sendData(customString, widget.services, context);
                textFieldController.clear();
              },
              child: Text(
                'Send',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: widget.services.length,
                itemBuilder: (context, index) {
                  return listItem(widget.services[index]);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget characteristicInfo(BluetoothService r) {
    String name = '';
    String properties = '';
    String data = '';
    // Display each characteristic one by one
    for (BluetoothCharacteristic c in r.characteristics) {
      properties = '';
      data = '';
      name += '\t\t${c.uuid}\n';
      if (c.properties.write) {
        properties += 'Write ';
      }
      if (c.properties.read) {
        properties += 'Read ';
      }
      if (c.properties.notify) {
        properties += 'Notify ';
        if (notifyDatas.containsKey(c.uuid.toString())) {
          // If notify data exists
          if (notifyDatas[c.uuid.toString()]!.isNotEmpty) {
            data = notifyDatas[c.uuid.toString()].toString();
          }
        }
      }
      if (c.properties.writeWithoutResponse) {
        properties += 'WriteWR ';
      }
      if (c.properties.indicate) {
        properties += 'Indicate ';
      }
      name += '\t\t\tProperties: $properties\n';
      if (data.isNotEmpty) {
        // Display received data!
        name += '\t\t\t\t$data\n';
      }
    }
    return Text(name);
  }

  /* Service UUID widget */
  Widget serviceUUID(BluetoothService r) {
    String name = '';
    name = r.uuid.toString();
    return Text(name);
  }

  /* Service information item widget */
  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      title: serviceUUID(r),
      subtitle: characteristicInfo(r),
    );
  }
}
