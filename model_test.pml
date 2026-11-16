// Define the number of floors and elevatorsin the building
#define NUM_FLOORS 5
#define NUM_ELEVATORS 2

// Define the possible states of the elevator
// mtype = {IDLE, MOVING_UP, MOVING_DOWN};

// Define the state variables for the elevator
byte elevator_floor[NUM_ELEVATORS];
// mtype elevator_state[NUM_ELEVATORS];

// Define the state variables for the doors
bit doorisopen[NUM_FLOORS * NUM_ELEVATORS];
bit ext_request[NUM_FLOORS];
bit int_request[NUM_ELEVATORS * NUM_FLOORS];

// Define the channels for communication between the elevator
// and the doors. {floor, elevator_id, door_state}
chan openclosedoor = [0] of {byte, byte, bit};

// Door(floor, elevator) process
proctype door(byte f; byte e) {
    do
    // Wait for a message from the elevator to open or close the door
    // Open the door
    ::  openclosedoor?eval(f),eval(e),1;
        doorisopen[(f-1)*NUM_ELEVATORS + (e-1)] = 1;
        printf("Door at floor %d, elevator %d opened.\n", f, e);
        openclosedoor!f,e,1;
    // Close the door
    ::  openclosedoor?eval(f),eval(e),0;
        doorisopen[(f-1)*NUM_ELEVATORS + (e-1)] = 0;
        printf("Door at floor %d, elevator %d closed.\n", f, e);
        openclosedoor!f,e,0;
    od
}

// Elevator(id) process
proctype elevator(byte id) {
    do
    // Move the elevator up or down one floor, if possible
    // Move up
    ::  (elevator_floor[id-1] < NUM_FLOORS &&
        doorisopen[(elevator_floor[id-1]-1)*NUM_ELEVATORS + (id-1)] == 0) ->
        elevator_floor[id-1]++;
        printf("Elevator %d moved up to floor %d.\n", id, elevator_floor[id-1]);
    // Move down
    ::  (elevator_floor[id-1] > 1 &&
        doorisopen[(elevator_floor[id-1]-1)*NUM_ELEVATORS + (id-1)] == 0) ->
        elevator_floor[id-1]--;
        printf("Elevator %d moved down to floor %d.\n", id, elevator_floor[id-1]);
    // Open or close the door on the current floor, if possible
    // Open the door
    ::  (doorisopen[(elevator_floor[id-1]-1)*NUM_ELEVATORS + (id-1)] == 0 &&
        (ext_request[elevator_floor[id-1]-1] == 1 || int_request[(id-1)*NUM_FLOORS + elevator_floor[id-1]-1] == 1)) -> 
        printf("Elevator %d requests to open its door at floor %d.\n", id, elevator_floor[id-1]);
        openclosedoor!elevator_floor[id-1],id,1;
        openclosedoor?eval(elevator_floor[id-1]),eval(id),1;
    // Close the door
    ::  (doorisopen[(elevator_floor[id-1]-1)*NUM_ELEVATORS + (id-1)] == 1) -> 
        printf("Elevator %d requests to close its door at floor %d.\n", id, elevator_floor[id-1]);
        openclosedoor!elevator_floor[id-1],id,0;
        openclosedoor?eval(elevator_floor[id-1]),eval(id),0
    od
}

// External_request(floor) process
proctype external_request(byte f) {
    // Send a request to the elevator to open the door on the specified floor
    do
    ::  (ext_request[f-1] == 0) ->
        ext_request[f-1] = 1;
        printf("External request registered at floor %d.\n", f);
    ::  openclosedoor?eval(f),_,1 ->
        ext_request[f-1] = 0;
        printf("External request at floor %d served.\n", f);
    od 
}

// Internal_request(elevator, floor) process
proctype internal_request(byte e; byte f) { 
    do
    :: (int_request[(e-1)*NUM_FLOORS + (f-1)] == 0) ->
        int_request[(e-1)*NUM_FLOORS + (f-1)] = 1;
        printf("Internal request registered: elevator %d, floor %d.\n", e, f);

    :: openclosedoor?eval(e),eval(f),1 ->
        int_request[(e-1)*NUM_FLOORS + (f-1)] = 0;
        printf("Internal request served: elevator %d, floor %d.\n", e, f);
    od
}


// Initialize the state variables and start the processes
init {
    atomic {
        printf("Elevator system initialized with %d floors and %d elevators.\n", NUM_FLOORS, NUM_ELEVATORS);
        run elevator(1);
        run elevator(2);

        elevator_floor[0] = 1;
        elevator_floor[1] = 1;
        // elevator_state[0] = IDLE;
        // elevator_state[1] = IDLE;

        run door(1, 1);
        run door(2, 1);
        run door(3, 1);
        run door(4, 1);
        run door(5, 1);

        run door(1, 2);
        run door(2, 2);
        run door(3, 2);
        run door(4, 2);
        run door(5, 2);

        run external_request(1);
        run external_request(2);
        run external_request(3);
        run external_request(4);
        run external_request(5);

        run internal_request(1, 1);
        run internal_request(1, 2);
        run internal_request(1, 3);
        run internal_request(1, 4);
        run internal_request(1, 5);
        run internal_request(2, 1);
        run internal_request(2, 2);
        run internal_request(2, 3);
        run internal_request(2, 4);
        run internal_request(2, 5);

        doorisopen[0] = 0;
        doorisopen[1] = 0;
        doorisopen[2] = 0;
        doorisopen[3] = 0;
        doorisopen[4] = 0;
        doorisopen[5] = 0;
        doorisopen[6] = 0;
        doorisopen[7] = 0;
        doorisopen[8] = 0;
        doorisopen[9] = 0;

        ext_request[0] = 0;
        ext_request[1] = 0;
        ext_request[2] = 0;
        ext_request[3] = 0;
        ext_request[4] = 0;

        int_request[0] = 0;
        int_request[1] = 0;
        int_request[2] = 0;
        int_request[3] = 0;
        int_request[4] = 0;
        int_request[5] = 0;
        int_request[6] = 0;
        int_request[7] = 0;
        int_request[8] = 0;
        int_request[9] = 0;
    }
}


// Declare macros for later Verification
// #define open1 doorisopen[0, 0]
// #define close1 !doorisopen[0, 0]

// #define open2 doorisopen[1, 0]
// #define close2 !doorisopen[1, 0]

// #define open3 doorisopen[2, 0]
// #define close3 !doorisopen[2, 0]

// // Declare LTL properties for verification
// ltl alldooropen {
//  [] (!open3)
// }
