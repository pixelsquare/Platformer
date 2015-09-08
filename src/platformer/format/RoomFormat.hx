package platformer.format;

/**
 * @author Anthony Ganzon
 */
typedef RoomFormat = {
	ROOM_DATA_ID: Int,
	
	RoomName: String,
	
	Background_Data: Array<Array<Int>>,
	
	Block_Data: Array<Array<Int>>,
	
	Obstacle_Data: Array<Array<Int>>,
	
	Door_Data: Array<Array<Int>>,
	
	Layer_Data: Array<Array<Int>>
}