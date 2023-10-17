/**
  Copyright (C) 2012-2018 by Autodesk, Inc.
  All rights reserved.

  Brother Speedio post processor configuration.

  $Date: 2019-01-25 11:40:52 $
  
*/

description = "Brother Speedio 2019-2-2";
vendor = "Brother";
vendorUrl = "http://www.brother.com";
legal = "Copyright (C) 2012-2018 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 40783;

longDescription = "Generic milling post for Brother Speedio S300X1, S500X1 and S700X1 machines.";

extension = "NC";
programNameIsInteger = false;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion



// user-defined properties
properties = {
  endProgramFirstTool: false,
  homeXaxis: -250,
  homeYaxis: 0,
  writeMachine: true, // write machine
  writeTools: true, // writes the tools
  preloadTool: true, // preloads next tool on tool change if any
  showSequenceNumbers: true, // show sequence numbers
  sequenceNumberStart: 10, // first sequence number
  sequenceNumberIncrement: 5, // increment for sequence numbers
  optionalStop: true, // optional stop
  o8: false, // specifies 8-digit program number
  separateWordsWithSpace: true, // specifies that the words should be separated with a white space
  useRadius: false, // specifies that arcs should be output using the radius (R word) instead of the I, J, and K words.
  useParametricFeed: false, // specifies that feed should be output using Q values
  showNotes: false, // specifies that operation notes should be output.
  useAAxis: false, // enables the A axis
  probingType: "Renishaw", // sets the probing style
  washdownCoolant: "off", // sets when/if washdown coolant should be used
  usePitchForTapping: true, // for tapping use TPI for Inch output and Pitch for MM output
  outputUnit: "same", // can be "same", "inch", or "mm"
  doubleTapWithdrawSpeed: false // if enabled, the withdraw speed of the tap is doubled
};

// user-defined property definitions
propertyDefinitions = {
  endProgramFirstTool: {title:"First Tool at End", description:"End the program either with the first tool or last tool, true for first tool", group:0, type:"boolean"},
  homeXaxis: {title:"Home X Axis", description:"X position to send machine at the end of program", group:1, type:"integer"},
  homeYaxis: {title:"Home Y Axis", description:"Y position to send machine at the end of program", group:1, type:"integer"},
  writeMachine: {title:"Write machine", description:"Output the machine settings in the header of the code.", group:0, type:"boolean"},
  writeTools: {title:"Write tool list", description:"Output a tool list in the header of the code.", group:0, type:"boolean"},
  preloadTool: {title:"Preload tool", description:"Preloads the next tool at a tool change (if any).", group:1, type:"boolean"},
  showSequenceNumbers: {title:"Use sequence numbers", description:"Use sequence numbers for each block of outputted code.", group:1, type:"boolean"},
  sequenceNumberStart: {title:"Start sequence number", description:"The number at which to start the sequence numbers.", group:1, type:"integer"},
  sequenceNumberIncrement: {title:"Sequence number increment", description:"The amount by which the sequence number is incremented by in each block.", group:1, type:"integer"},
  optionalStop: {title:"Optional stop", description:"Outputs optional stop code during when necessary in the code.", type:"boolean"},
  o8: {title:"8 Digit program number", description:"Specifies that an 8 digit program number is needed.", type:"boolean"},
  separateWordsWithSpace: {title:"Separate words with space", description:"Adds spaces between words if 'yes' is selected.", type:"boolean"},
  useRadius: {title:"Radius arcs", description:"If yes is selected, arcs are outputted using radius values rather than IJK.", type:"boolean"},
  useParametricFeed:  {title:"Parametric feed", description:"Specifies the feed value that should be output using a Q value.", type:"boolean"},
  showNotes: {title:"Show notes", description:"Writes operation notes as comments in the outputted code.", type:"boolean"},
  useAAxis: {title: "Use A-axis", description: "Specifies whether to use the A axis.", type: "boolean"},
  probingType: {title: "Probing type", desctiption: "Specified what probing cycles are used on the machine.", type: "enum", values: [{title: "Renishaw", id: "Renishaw"}, {title: "Blum", id: "Blum"}]},
  washdownCoolant: {title: "Washdown coolant", desctiption: "Specifies whether washdown coolant should be used and where it is output.", type: "enum", values:[{title: "Off", id: "off"}, {title: "Always on", id: "always"}, {title: "End of operation", id: "operationEnd"}, {title: "Program end", id:"programEnd"}]},
  usePitchForTapping: {title:"Use Pitch/TPI for tapping", description:"Selects whether the feedrate, or pitch in MM or TPI for Inch is output for tapping cycles.", type:"boolean"},
  outputUnit: {
    title: "Output units",
    description: "Select output units, can be same as input or forced to be Inch or MM.",
    type: "enum",
    values:[
      {title:"Same as input", id:"same"},
      {title:"Inch", id:"inch"},
      {title:"MM", id:"mm"}
    ]
  },
  doubleTapWithdrawSpeed: {title:"Double tap withdraw speed", description:"If enabled, a L value containing double the spindle speed (up to 6000) will be output in the G77 tapping cycle.", type: "boolean"}
};

// samples:
// throughTool: {on: 88, off: 89}
// throughTool: {on: [8, 88], off: [9, 89]}
var coolants = {
  flood: {on: 8},
  mist: {},
  throughTool: {on: 494, off: 495},
  air: {},
  airThroughTool: {},
  suction: {},
  floodMist: {},
  floodThroughTool: {on: [8, 494], off: [9, 495]},
  washdown: {on: 400, off: 401},
  off: 9
};


var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-";

var gFormat = createFormat({prefix:"G", width:2, zeropad:true, decimals:1});
var mFormat = createFormat({prefix:"M", width:2, zeropad:true, decimals:1});
var hFormat = createFormat({prefix:"H", width:2, zeropad:true, decimals:1});
var dFormat = createFormat({prefix:"D", width:2, zeropad:true, decimals:1});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:false});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 0 : 1), forceDecimal:false});
var toolFormat = createFormat({width:2, zeropad:true, decimals:1});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange: function() {retracted = false;}, prefix: "Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var cyclefeedOutput = createVariable({prefix:"F", force:true}, feedFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I"}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J"}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K"}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G94-95
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({force:true}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99
var gRotationModal = createModal({}, gFormat); // modal group 16 // G68-G69

// fixed settings
var firstFeedParameter = 500;
var useMultiAxisFeatures = false;
var forceMultiAxisIndexing = false; // force multi-axis indexing for 3D programs
var cancelTiltFirst = false; // cancel G68.2 with G69 prior to G54-G59 WCS block
var useABCPrepositioning = false; // position ABC axes prior to G68.2 block

var WARNING_WORK_OFFSET = 0;

var ANGLE_PROBE_NOT_SUPPORTED = 0;
var ANGLE_PROBE_USE_ROTATION = 1;
var ANGLE_PROBE_USE_CAXIS = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var retracted = false; // specifies that the tool has been retracted to the safe plane
var g68RotationMode = 0;
var angularProbingMode;

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  if (properties.showSequenceNumbers) {
    if (optionalSection) {
      if (text) {
        writeWords("/", "N" + sequenceNumber, text);
      }
    } else {
      writeWords2("N" + sequenceNumber, arguments);
    }
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(arguments);
  }
}

/**
  Writes the specified optional block.
*/
function writeOptionalBlock() {
  if (properties.showSequenceNumbers) {
    var words = formatWords(arguments);
    if (words) {
      writeWords("/", "N" + sequenceNumber, words);
      sequenceNumber += properties.sequenceNumberIncrement;
    }
  } else {
    writeWords("/", arguments);
  }
}

function formatComment(text) {
  return "(" + filterText(String(text).toUpperCase(), permittedCommentChars).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function onOpen() {
  if (properties.useRadius) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }
  gRotationModal.format(69); // Default to G69 Rotation Off

  if (properties.useAAxis) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-360, 360], preference:1});
    machineConfiguration = new MachineConfiguration(aAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(0); // TCP mode
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    cOutput.disable();
  }
  
  if (!properties.separateWordsWithSpace) {
    setWordSeparator("");
  }

  sequenceNumber = properties.sequenceNumberStart;

    if (programName) {
    if (programComment) {
      writeComment(programName + " (" + filterText(String(programComment).toUpperCase(), permittedCommentChars) + ")");
    } else {
      writeComment(programName);
    }
  } else {
    error(localize("Program name has not been specified."));
    return;
  }
  

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (properties.writeMachine && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }

  // dump tool information
  if (properties.writeTools) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = "T" + toolFormat.format(tool.number) + " " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }
  
  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (xyzFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              xyzFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(gFormat.format(0), gAbsIncModal.format(90), gFormat.format(40), gFormat.format(80));
  writeBlock(gFeedModeModal.format(94), gFormat.format(49));

  writeComment("File output in " + (unit == 1 ? "MM" : "inches") + ". Please ensure the unit is set correctly on the control");
}

function onComment(message) {
  var comments = String(message).split(";");
  for (comment in comments) {
    writeComment(comments[comment]);
  }
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

var currentSmoothing = false;

function setSmoothing(mode, lengthCompensationActive) {
  if (mode == currentSmoothing) {
    return false;
  }
  currentSmoothing = mode;
  if (lengthCompensationActive) {
    writeBlock(gFormat.format(49));
  }
  writeBlock(gFormat.format(5.1), mode ? "Q1" : "Q0");
  return true;
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  
  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }
  
  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  
/*
  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }
*/

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }
  
  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function cancelWorkPlane() {
  writeBlock(gRotationModal.format(69)); // cancel frame
  forceWorkPlane();
}

function setWorkPlane(abc) {
  if (!forceMultiAxisIndexing && is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  if (!retracted) {
    if (!properties.useAAxis) {
      writeRetract(Z);
    }
  }

  if (useMultiAxisFeatures) {
    if (cancelTiltFirst) {
      cancelWorkPlane();
    }
    if (machineConfiguration.isMultiAxisConfiguration() && useABCPrepositioning) {
      var angles = abc.isNonZero() ? getWorkPlaneMachineABC(currentSection.workPlane, false, false) : abc;
      gMotionModal.reset();
      writeBlock(
        gMotionModal.format(0),
        conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(angles.x)),
        conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(angles.y)),
        conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(angles.z))
      );
    }
    if (abc.isNonZero()) {
      gRotationModal.reset();
      writeBlock(gRotationModal.format(68.2), "X" + xyzFormat.format(0), "Y" + xyzFormat.format(0), "Z" + xyzFormat.format(0), "I" + abcFormat.format(abc.x), "J" + abcFormat.format(abc.y), "K" + abcFormat.format(abc.z)); // set frame
      writeBlock(gFormat.format(53.1)); // turn machine
    } else {
      if (!cancelTiltFirst) {
        cancelWorkPlane();
      }
    }
  } else {
    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    var _a = aOutput.format(abc.x);
    var _b = bOutput.format(abc.y);
    var _c = cOutput.format(abc.z);
    if (_a || _b || _c) {
      gMotionModal.reset();
      writeBlock(
        gMotionModal.format(0),
        conditional(machineConfiguration.isMachineCoordinate(0), _a),
        conditional(machineConfiguration.isMachineCoordinate(1), _b),
        conditional(machineConfiguration.isMachineCoordinate(2), _c),
        xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
      );
    }
  }
  
  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane, _setWorkPlane, rotate) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    if (_setWorkPlane) {
      currentMachineABC = abc;
    }
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }
  
  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }
  
  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  if (rotate) {
    var tcp = false;
    if (tcp) {
      setRotation(W); // TCP mode
    } else {
      var O = machineConfiguration.getOrientation(abc);
      var R = machineConfiguration.getRemainingOrientation(abc, W);
      setRotation(R);
    }
  }
  
  return abc;
}

function isProbeOperation() {
  return hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");
}

var probeOutputWorkOffset = 1;

function onParameter(name, value) {
  if (name == "probe-output-work-offset") {
    probeOutputWorkOffset = (value > 0) ? value : 1;
  }
}

function onSection() {
  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  var insertToolCall = forceToolAndRetract || isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);
  
  retracted = false;
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  if (insertToolCall || newWorkOffset || newWorkPlane) {
    
    // stop spindle before retract during tool change
    if (insertToolCall && !isFirstSection()) {
      onCommand(COMMAND_STOP_SPINDLE);
    }
    
    if (!insertToolCall) {
      // retract to safe plane
      writeRetract(Z); // retract
      forceXYZ();
    }
  }

  writeln("");

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }
  
  if (properties.showNotes && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  if (workOffset != currentWorkOffset) {
    if (cancelTiltFirst) {
      cancelWorkPlane();
    }
    forceWorkPlane();
  }
  if (workOffset > 0) {
    if (workOffset > 6) {
      var p = workOffset - 6; // 1->...
      if (p > 300) {
        error(localize("Work offset out of range."));
        return;
      } else {
        if (workOffset != currentWorkOffset) {
          writeBlock(gFormat.format(54.1), "P" + p); // G54.1P
          currentWorkOffset = workOffset;
        }
      }
    } else {
      if (workOffset != currentWorkOffset) {
        writeBlock(gFormat.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }

  if (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    if (currentSection.isMultiAxis()) {
      forceWorkPlane();
      cancelTransformation();
    } else {
      var abc = new Vector(0, 0, 0);
      if (useMultiAxisFeatures) {
        var euler = currentSection.workPlane.getEuler2(EULER_ZXZ_R);
        abc = new Vector(euler.x, euler.y, euler.z);
        cancelTransformation();
      } else {
        abc = getWorkPlaneMachineABC(currentSection.workPlane, true, true);
      }
      // setWorkPlane will be called below
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }
  
  if (insertToolCall) {
    forceWorkPlane();
    
    setCoolant(COOLANT_OFF);

    if (!isFirstSection() && properties.optionalStop) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if (tool.number > 99) {
      warning(localize("Tool number exceeds maximum value."));
    }

    if (!isProbeOperation() && (insertToolCall ||
      isFirstSection() ||
      (rpmFormat.areDifferent(spindleSpeed, getPreviousSection().getTool().spindleRPM)) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise))) {
      if (spindleSpeed < 1) {
        error(localize("Spindle speed out of range."));
        return;
      }
      if (spindleSpeed > 99999) {
        warning(localize("Spindle speed exceeds maximum value."));
      }
    }
  
    var start = getFramePosition(currentSection.getInitialPosition());
  
    writeBlock(gFormat.format(100),
      "T" + toolFormat.format(tool.number),
      xOutput.format(start.x),
      yOutput.format(start.y),
      gFormat.format(43),
      zOutput.format(start.z),
      ((properties.useAAxis && abc) ? aOutput.format(abc.x) : undefined),
      hFormat.format(tool.lengthOffset),
      (!isProbeOperation() ? dFormat.format(tool.diameterOffset) : ""),
      (!isProbeOperation() ? sOutput.format(spindleSpeed) : ""),
      (!isProbeOperation() ? mFormat.format(tool.clockwise ? 3 : 4) : "")
    );
    
    if (tool.comment) {
      writeComment(tool.comment);
    }
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }

    if (properties.preloadTool) {
      var nextTool = getNextTool(tool.number);
      if (nextTool) {
        writeBlock("T" + toolFormat.format(nextTool.number));
      } else {
        // preload first tool
        var section = getSection(0);
        var firstToolNumber = section.getTool().number;
        if (tool.number != firstToolNumber) {
          writeBlock("T" + toolFormat.format(firstToolNumber));
        }
      }
    }
  }
  


  onCommand(COMMAND_START_CHIP_TRANSPORT);
  if (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) {
    // writeBlock(mFormat.format(xxx)); // shortest path traverse
  }


  if (!insertToolCall) {
    forceXYZ();
  }

  if (abc !== undefined) {
    setWorkPlane(abc);
  }

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);
  // add dwell for through coolant if needed
  if (tool.coolant == COOLANT_THROUGH_TOOL || tool.coolant == COOLANT_AIR_THROUGH_TOOL || tool.coolant == COOLANT_FLOOD_THROUGH_TOOL) {
    if (isFirstSection()) {
      onDwell(1);
    } else {
      var lastCoolant = getPreviousSection().getTool().coolant;
      if (!(lastCoolant == COOLANT_THROUGH_TOOL || lastCoolant == COOLANT_AIR_THROUGH_TOOL || lastCoolant == COOLANT_FLOOD_THROUGH_TOOL)) {
        onDwell(1);
      }
    }
  }

  if (false) {
    if (hasParameter("operation-strategy") && (getParameter("operation-strategy") != "drill")) {
      if (setSmoothing(true, !retracted)) {
        // retracted = true; // force G43
      }
    } else {
      if (setSmoothing(false, !retracted)) {
        // retracted = true; // force G43
      }
    }
  }

  forceAny();
  gMotionModal.reset();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    }
  }

  if (isFirstSection() && (properties.washdownCoolant == "always")) {
    writeBlock(mFormat.format(coolants.washdown.on));
  }

  if (insertToolCall || retracted || (!isFirstSection() && getPreviousSection().isMultiAxis())) {
    var lengthOffset = tool.lengthOffset;
    if (lengthOffset > 99) {
      error(localize("Length offset out of range."));
      return;
    }

    writeBlock(gPlaneModal.format(17));
    
    if (!machineConfiguration.isHeadConfiguration()) {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
      );
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z)
      );
    }

    gMotionModal.reset();
  } else {
    writeBlock(
      gAbsIncModal.format(90),
      gMotionModal.format(0),
      xOutput.format(initialPosition.x),
      yOutput.format(initialPosition.y)
    );
  }

  if (properties.useParametricFeed &&
    hasParameter("operation-strategy") &&
    (getParameter("operation-strategy") != "drill") && // legacy
    !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
      activeMovements &&
      (getCurrentSectionId() > 0) &&
      ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }

  if (isProbeOperation()) {
    if (g68RotationMode != 0) {
      error(localize("You cannot probe while G68 Rotation is in effect."));
      return;
    }
    angularProbingMode = getAngularProbingMode();
    if (properties.probingType == "Renishaw") {
      writeBlock(gFormat.format(65), "P" + 8832); // spin the probe on
    }
  }

}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(1, seconds, 99999999);
  writeBlock(gFeedModeModal.format(94), gFormat.format(4), "P" + secFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

function onCycle() {
  writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) {
  forceXYZ(); // force xyz on first drill hole of any cycle
  return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R" + xyzFormat.format(r)];
}

/** Convert approach to sign. */
function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

/**
  Determine if angular probing is supported
*/
function getAngularProbingMode() {
  if (machineConfiguration.isMultiAxisConfiguration()) {
    if (machineConfiguration.isMachineCoordinate(2)) {
      return ANGLE_PROBE_USE_CAXIS;
    } else {
      return ANGLE_PROBE_NOT_SUPPORTED;
    }
  } else {
    return ANGLE_PROBE_USE_ROTATION;
  }
}

/**
  Output rotation offset based on angular probing cycle.
*/
function setProbingAngle() {
  if ((g68RotationMode == 1) || (g68RotationMode == 2)) { // Rotate coordinate system for Angle Probing
    if (!properties.useG54x4) {
      gRotationModal.reset();
      gAbsIncModal.reset();
      writeBlock(
        gRotationModal.format(68), gAbsIncModal.format(90),
        (g68RotationMode == 1) ? "X0" : "X[#135]",
        (g68RotationMode == 1) ? "Y0" : "Y[#136]",
        "Z0", "I0.0", "J0.0", "K1.0", "R[#139]"
      );
      g68RotationMode = 3;
    } else if (angularProbingMode != ANGLE_PROBE_NOT_SUPPORTED) {
      writeBlock("#26010=#135");
      writeBlock("#26011=#136");
      writeBlock("#26012=#137");
      writeBlock("#26015=#139");
      writeBlock(gFormat.format(54.4), "P1");
      g68RotationMode = 0;
    } else {
      error(localize("Angular probing is not supported for this machine configuration."));
      return;
    }
  }
}

function onCyclePoint(x, y, z) {
  var probeWorkOffsetCode;
  if (isProbeOperation()) {
    if (!useMultiAxisFeatures && !isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) && (!cycle.probeMode || (cycle.probeMode == 0))) {
      error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
      return;
    }
    var workOffset = probeOutputWorkOffset ? probeOutputWorkOffset : currentWorkOffset;
    if (workOffset > 99) {
      error(localize("Work offset is out of range."));
      return;
    } else if (workOffset > 6) {
      var p = workOffset - 6; // 1->...
      probeWorkOffsetCode = -p; // G54.1P
    } else {
      probeWorkOffsetCode = ((properties.probingType == "Renishaw") ? ("G" + workOffset + ".") : (workOffset + 53)); // G54->G59
    }
  }

  if (isFirstCyclePoint()) {
    repositionToCycleClearance(cycle, x, y, z);
    
    // return to initial Z which is clearance plane and set absolute mode

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell, 99999999); // in seconds

    // tapping variables
    var tapUnit = unit;
    if (hasParameter("operation:tool_unit")) {
      if (getParameter("operation:tool_unit") == "inches") {
        tapUnit = IN;
      } else {
        tapUnit = MM;
      }
    }
    var threadPitch = tool.threadPitch;
    if (unit != tapUnit) {
      threadPitch /= (tapUnit == IN) ? 25.4 : (1.0 / 25.4);
    }

    var threadsPerInch = 1.0 / threadPitch;


    switch (cycleType) {
    case "drilling":
      writeBlock(
        gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract),
        cyclefeedOutput.format(F)
      );
      break;
    case "counter-boring":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(81),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "chip-breaking":
      // cycle.accumulatedDepth is ignored
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(73),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "deep-drilling":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(83),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          // conditional(P > 0, "P" + secFormat.format(P)),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "tapping":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (properties.usePitchForTapping) {
        writeBlock(
          gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(properties.doubleTapWithdrawSpeed, "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "left-tapping":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (properties.usePitchForTapping) {
        writeBlock(
          gCycleModal.format(74),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(properties.doubleTapWithdrawSpeed, "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format(74),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "right-tapping":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (properties.usePitchForTapping) {
        writeBlock(
          gCycleModal.format(77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(properties.doubleTapWithdrawSpeed, "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format(77),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "tapping-with-chip-breaking":
    case "left-tapping-with-chip-breaking":
    case "right-tapping-with-chip-breaking":
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      if (properties.usePitchForTapping) {
        writeBlock(
          gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 77),
          getCommonCycle(x, y, cycle.bottom, cycle.retract),
          conditional((P != 0), "P" + secFormat.format(P)),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          conditional((tapUnit == IN), "J" + xyzFormat.format(threadsPerInch)),
          conditional((tapUnit == MM), "I" + xyzFormat.format(threadPitch)),
          conditional(properties.doubleTapWithdrawSpeed, "L" + (spindleSpeed * 2 > 6000 ? 6000 : spindleSpeed * 2))
        );
      } else {
        writeBlock(
          gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND ? 74 : 77)),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          feedOutput.format(F)
        );
      }
      break;
    case "fine-boring":
      writeBlock(
        gCycleModal.format(76),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P), // not optional
        "Q" + xyzFormat.format(cycle.shift),
        feedOutput.format(F)
      );
      break;
    case "back-boring":
      var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
      var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
      var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
      writeBlock(
        gCycleModal.format(87),
        getCommonCycle(x, y, cycle.bottom - cycle.backBoreDistance, cycle.bottom),
        "Q" + xyzFormat.format(cycle.shift),
        "P" + secFormat.format(P), // not optional
        cyclefeedOutput.format(F)
      );
      break;
    case "reaming":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          cyclefeedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "stop-boring":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(86),
          getCommonCycle(x, y, z, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "manual-boring":
      writeBlock(
        gCycleModal.format(88),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P), // not optional
        cyclefeedOutput.format(F)
      );
      break;
    case "boring":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          cyclefeedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          cyclefeedOutput.format(F)
        );
      }
      break;
    case "probing-x":
      forceXYZ();
      // move slowly always from clearance not retract
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8811,
          "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "S" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z - cycle.depth)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "X" + xyzFormat.format(approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-y":
      forceXYZ();
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8811,
          "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "S" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z - cycle.depth)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "Y" + xyzFormat.format(approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-z":
      forceXYZ();
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract)), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8811,
          "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "S" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract))); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "Z" + xyzFormat.format(-cycle.depth),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-x-wall":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          zOutput.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          "S" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "X1",
          zOutput.format(-cycle.depth),
          "R" + xyzFormat.format(cycle.probeClearance),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-y-wall":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width1),
          zOutput.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(cycle.probeClearance),
          "S" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          zOutput.format(-cycle.depth),
          "Y1",
          "R" + xyzFormat.format(cycle.probeClearance),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-x-channel":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          "S" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "X1",
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-x-channel-with-island":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          zOutput.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + xyzFormat.format(cycle.width1),
          zOutput.format(-cycle.depth),
          "X1",
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-y-channel":
      yOutput.reset();
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "Y1",
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-y-channel-with-island":
      yOutput.reset();
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width1),
          zOutput.format(z - cycle.depth),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + xyzFormat.format(cycle.width1),
          zOutput.format(-cycle.depth),
          "Y1",
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-xy-circular-boss":
      if (properties.probingType == "Renishaw") {
          writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
          writeBlock(
            gFormat.format(65), "P" + 8814,
            "D" + xyzFormat.format(cycle.width1),
            "Z" + xyzFormat.format(z - cycle.depth),
            "Q" + xyzFormat.format(cycle.probeOvertravel),
            "R" + xyzFormat.format(cycle.probeClearance),
            "S" + probeWorkOffsetCode
          );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "Z" + xyzFormat.format(-cycle.depth),
          "R" + xyzFormat.format(cycle.probeClearance),
          "W" + probeWorkOffsetCode
        );
      }
      break;
    case "probing-xy-circular-hole":
      if (properties.probingType == "Renishaw") {
          writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
          writeBlock(
            gFormat.format(65), "P" + 8814,
            "D" + xyzFormat.format(cycle.width1),
            "Q" + xyzFormat.format(cycle.probeOvertravel),
            // not required "R" + xyzFormat.format(cycle.probeClearance),
            "S" + probeWorkOffsetCode
          );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "W" + probeWorkOffsetCode
        );
      }
      break;
    case "probing-xy-circular-hole-with-island":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8814,
          "Z" + xyzFormat.format(z - cycle.depth),
          "D" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
      } else {
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + xyzFormat.format(cycle.width1),
          zOutput.format(-cycle.depth),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-xy-rectangular-hole":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "X" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Y" + xyzFormat.format(cycle.width2),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
      } else {
        error(localize("XY rectangular hole probing is not supported."));
      }
      break;
    case "probing-xy-rectangular-boss":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "X" + xyzFormat.format(cycle.width1),
          "R" + xyzFormat.format(cycle.probeClearance),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "S" + probeWorkOffsetCode
        );
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "Y" + xyzFormat.format(cycle.width2),
          "R" + xyzFormat.format(cycle.probeClearance),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "S" + probeWorkOffsetCode
        );
      } else {
        zOutput.reset();
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width1),
          "X1",
          zOutput.format(-cycle.depth),
          "R" + xyzFormat.format(cycle.probeClearance),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
        zOutput.reset();
        writeBlock(
          gFormat.format(65), "P" + 8700,
          "S" + xyzFormat.format(cycle.width2),
          "Y1",
          zOutput.format(-cycle.depth),
          "R" + xyzFormat.format(cycle.probeClearance),
          "W" + probeWorkOffsetCode // "T" + toolFormat.format(probeToolDiameterOffset)
        );
      }
      break;
    case "probing-xy-rectangular-hole-with-island":
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "X" + xyzFormat.format(cycle.width1),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
        writeBlock(
          gFormat.format(65), "P" + 8812,
          "Z" + xyzFormat.format(z - cycle.depth),
          "Y" + xyzFormat.format(cycle.width2),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          "R" + xyzFormat.format(-cycle.probeClearance),
          "S" + probeWorkOffsetCode
        );
      } else {
        error(localize("XY rectangular hole with island probing is not supported."));
      }
      break;
    case "probing-xy-inner-corner":
      if (properties.probingType == "Renishaw") {
        var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
        var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
        var cornerI = 0;
        var cornerJ = 0;
        if (cycle.probeSpacing !== undefined) {
          cornerI = cycle.probeSpacing;
          cornerJ = cycle.probeSpacing;
        }
        if ((cornerI != 0) && (cornerJ != 0)) {
          g68RotationMode = 2;
        }
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8815, xOutput.format(cornerX), yOutput.format(cornerY),
          conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
          conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          conditional((g68RotationMode == 0) || (angularProbingMode == ANGLE_PROBE_USE_CAXIS), "S" + probeWorkOffsetCode)
        );
      } else {
        error(localize("XY inner corner probing is not supported."));
      }
      break;
    case "probing-xy-outer-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing !== undefined) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        g68RotationMode = 2;
      }
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8816, xOutput.format(cornerX), yOutput.format(cornerY),
          conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
          conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
          "Q" + xyzFormat.format(cycle.probeOvertravel),
          conditional((g68RotationMode == 0) || (angularProbingMode == ANGLE_PROBE_USE_CAXIS), "S" + probeWorkOffsetCode)
        );
      } else {
        cornerX -= x;
        cornerY -= y;
        writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8700, xOutput.format(cornerX),
          yOutput.format(cornerY), "W" + probeWorkOffsetCode
        );
      }
      break;
    case "probing-x-plane-angle":
      forceXYZ();
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8843,
          "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "D" + xyzFormat.format(cycle.probeSpacing),
          "Q" + xyzFormat.format(cycle.probeOvertravel)
        );
        g68RotationMode = 1;
      } else {
        error(localize("X angle probing is not supported."));
      }
      break;
    case "probing-y-plane-angle":
      forceXYZ();
      if (properties.probingType == "Renishaw") {
        writeBlock(gFormat.format(65), "P" + 8810, zOutput.format(z - cycle.depth), getFeed(F)); // protected positioning move
        writeBlock(
          gFormat.format(65), "P" + 8843,
          "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
          "D" + xyzFormat.format(cycle.probeSpacing),
          "Q" + xyzFormat.format(cycle.probeOvertravel)
        );
        g68RotationMode = 1;
      } else {
        error(localize("Y angle probing is not supported."));
      }
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      writeBlock(xOutput.format(x), yOutput.format(y));
    }
  }
}

function onCycleEnd() {
  if (isProbeOperation()) {
    if (properties.probingType == "Renishaw") {
      writeBlock(gFormat.format(65), "P" + 9810, zOutput.format(cycle.clearance)); // protected retract move
      writeBlock(gFormat.format(65), "P" + 9833); // spin the probe off
      setProbingAngle(); // define rotation of part
      // we can move in rapid from retract optionally
    } else {
      writeBlock(gFormat.format(65), "P" + 8703, zOutput.format(cycle.clearance)); // protected retract move
    }
  } else if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    zOutput.reset();
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    forceFeed();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      var d = tool.diameterOffset;
      if (d > 99) {
        warning(localize("The diameter offset exceeds the maximum value."));
      }
      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, dOutput.format(d), f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, dOutput.format(d), f);
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
  } else {
    forceXYZ();
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var i = ijkFormat.format(_a);
    var j = ijkFormat.format(_b);
    var k = ijkFormat.format(_c);
    writeBlock(gMotionModal.format(0), x, y, z, "I" + i, "J" + j, "K" + k);
  }
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    var f = getFeed(feed);
    if (x || y || z || a || b || c) {
      writeBlock(gMotionModal.format(1), x, y, z, a, b, c, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gMotionModal.format(1), f);
      }
    }
  } else {
    forceXYZ();
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var i = ijkFormat.format(_a);
    var j = ijkFormat.format(_b);
    var k = ijkFormat.format(_c);
    var f = getFeed(feed);
    if (x || y || z || i || j || k) {
      writeBlock(gMotionModal.format(1), x, y, z, "I" + i, "J" + j, "K" + k, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gMotionModal.format(1), f);
      }
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (properties.useRadius || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!properties.useRadius) {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > 180) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;
var firstThrough = true;
var addDwell = false;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    for (var c in coolantCodes) {
      writeBlock(coolantCodes[c]);
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (!coolantOff) { // use the default coolant off command when an 'off' value is not specified for the previous coolant mode
    coolantOff = coolants.off;
  }

  if (coolant == currentCoolantMode) {
    return undefined; // coolant is already active
  }

  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF)) {
    multipleCoolantBlocks.push(mFormat.format(coolantOff));
  }

  var m;
  if (coolant == COOLANT_OFF) {
    m = coolantOff;
    coolantOff = coolants.off;
  }

  switch (coolant) {
  case COOLANT_FLOOD:
    if (!coolants.flood) {
      break;
    }
    m = coolants.flood.on;
    coolantOff = coolants.flood.off;
    break;
  case COOLANT_THROUGH_TOOL:
    if (!coolants.throughTool) {
      break;
    }
    m = coolants.throughTool.on;
    coolantOff = coolants.throughTool.off;
    break;
  case COOLANT_AIR:
    if (!coolants.air) {
      break;
    }
    m = coolants.air.on;
    coolantOff = coolants.air.off;
    break;
  case COOLANT_AIR_THROUGH_TOOL:
    if (!coolants.airThroughTool) {
      break;
    }
    m = coolants.airThroughTool.on;
    coolantOff = coolants.airThroughTool.off;
    break;
  case COOLANT_FLOOD_MIST:
    if (!coolants.floodMist) {
      break;
    }
    m = coolants.floodMist.on;
    coolantOff = coolants.floodMist.off;
    break;
  case COOLANT_MIST:
    if (!coolants.mist) {
      break;
    }
    m = coolants.mist.on;
    coolantOff = coolants.mist.off;
    break;
  case COOLANT_SUCTION:
    if (!coolants.suction) {
      break;
    }
    m = coolants.suction.on;
    coolantOff = coolants.suction.off;
    break;
  case COOLANT_FLOOD_THROUGH_TOOL:
    if (!coolants.floodThroughTool) {
      break;
    }
    m = coolants.floodThroughTool.on;
    coolantOff = coolants.floodThroughTool.off;
    break;
  }
  
  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  }

  if (m) {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(mFormat.format(m[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(m));
    }
    currentCoolantMode = coolant;
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}


var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:2,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19
};

function onCommand(command) {
  switch (command) {
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  }
  
  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  if (currentSection.isMultiAxis() && !currentSection.isOptimizedForMachine()) {
    writeBlock(gFormat.format(49));
  }
  setSmoothing(false);
  writeBlock(gPlaneModal.format(17));

  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }
  if (!isProbeOperation() && properties.washdownCoolant == "operationEnd") {
    writeBlock(mFormat.format(coolants.washdown.on));
    writeBlock(mFormat.format(coolants.washdown.off));
  }
  forceAny();
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  if (arguments.length == 0) {
    error(localize("No axis specified for writeRetract()."));
    return;
  }
  var words = []; // store all retracted axes in an array
  for (var i = 0; i < arguments.length; ++i) {
    let instances = 0; // checks for duplicate retract calls
    for (var j = 0; j < arguments.length; ++j) {
      if (arguments[i] == arguments[j]) {
        ++instances;
      }
    }
    if (instances > 1) { // error if there are multiple retract calls for the same axis
      error(localize("Cannot retract the same axis twice in one line"));
      return;
    }
    switch (arguments[i]) {
    case X:
      if (machineConfiguration.hasHomePositionX()) {
        words.push("X" + xyzFormat.format(machineConfiguration.getHomePositionX()));
      }
      break;
    case Y:
      if (machineConfiguration.hasHomePositionY()) {
        words.push("Y" + xyzFormat.format(machineConfiguration.getHomePositionY()));
      }
    break;
    case Z:
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), "Z" + xyzFormat.format(machineConfiguration.getRetractPlane())); // retract
      writeBlock(gAbsIncModal.format(90));
      retracted = true; // specifies that the tool has been retracted to the safe plane
      zOutput.reset();
      break;
    default:
      error(localize("Bad axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    gMotionModal.reset();
      gAbsIncModal.reset();
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), words); // retract
  }

}

function onClose() {
  writeln("");
  optionalSection = false;

  setCoolant(COOLANT_OFF);
  if (!isProbeOperation() && (properties.washdownCoolant == "always") || properties.washdownCoolant == "programEnd") {
    if (properties.washdownCoolant == "programEnd") {
      writeBlock(mFormat.format(coolants.washdown.on));
    }
    writeBlock(mFormat.format(coolants.washdown.off));
  }


  if(properties.endProgramFirstTool){
      // reload first tool (handles retract)
      writeBlock(gFormat.format(100), "T" + toolFormat.format(getSection(0).getTool().number));
  }
  else{
      // first stop spindle
      writeBlock(mFormat.format(5));
      // keep last tool, retract Z
      writeBlock(gFormat.format(53), "Z" + xyzFormat.format(unit == MM ? 480 : 18.89));
  }
  // send machine to user defined home position
  writeBlock(gFormat.format(53), "X" + xyzFormat.format(properties.homeXaxis), "Y" + xyzFormat.format(properties.homeYaxis));
  
  setWorkPlane(new Vector(0, 0, 0)); // reset working plane
 
  writeRetract(X, Y);

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
}
