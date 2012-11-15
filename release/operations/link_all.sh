cat _MockGroup.coffee > brain.coffee
echo -e '\n' >> brain.coffee
cat Operations.coffee >> brain.coffee
echo -e '\n' >> brain.coffee
cat Visualizators.coffee >> brain.coffee
echo -e '\n' >> brain.coffee
cat Core.coffee >> brain.coffee

coffee -c brain.coffee
rm brain.coffee

mv brain.js ../