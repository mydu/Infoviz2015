###Infoviz Assignment

###Instruction

* #### Data preporcessing
	Create a new column "density"= "population"/"surface"
* #### Data mapping
	1. Population - radius of circle, higher population with larger raduis
	2. Population - Opacity of circle, higher population with lower opacity, which is to handle the overlapping issues
	3. Density - Brightness(HSB colormode)of circle, higher density with higher brightness
	
		![preview](https://raw.githubusercontent.com/mydu/Infoviz2015/master/preview.png =400x350)
	
* #### Interaction
	1. Mousemove - Highlight places， with excentric labelling for overlapping cites
	2. click - Select Place for details
	3. two sliders for population and density control
	4. zoom and pan supported
	
* #### Running at your side
	Install ControlP5 library first and then run the `assignment.pde`
	
	<http://www.sojamo.de/libraries/controlP5/>