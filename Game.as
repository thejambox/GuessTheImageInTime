package 
{
	import flash.display.*;
	import flash.events.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageSize;
	import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageType;

	public class Game extends MovieClip
	{
		public static const MASTER_KEYWORDS:Vector.<String> = Vector.<String>([
			"dog",
			"cat",
			"boat",
			"train",
			"car",
			"cow",
			"turtle",
			"snake",
			"house",
			"truck",
			"horse",
			"plane",
			"frog",
			"deer",
			"goat",
			"gun",
			"castle",
			"bike",
			"moon",
			"sun",
			"shark",
			"fish",
			"eel",
			"giraffe",
			"zebra",
			"book",
			"bear",
			"lion",
			"tiger",
			"panther",
			"eagle",
			"hawk",
			"pigeon",
			"chipmunk",
			"fox",
			"chicken",
			"rooster",
			"snail",
			"slug",
			"dolphin",
			"whale",
			"octopus",
			"seal",
			"sheep",
			"rocket",
			"shell",
			"tank",
			"tree",
			"tire",
			"berry",
			"beer",
			"cookie",
			"cake",
			"moose",
			"kite",
			"mouse",
			"balloon",
			"piano",
			"guitar",
			"flute",
			"chair",
			"table",
			"computer",
			"rug",
			"blanket",
			"bed",
			"sink",
			"stool",
			"brush",
			"rock",
			"jar",
			"mirror",
			"lamp",
			"llama",
			"hamster",
			"lemon",
			"apple",
			"banana",
			"salad",
			"canoe",
			"orange",
			"demon",
			"monster",
			"harp",
			"cup",
			"camel",
			"ufo",
			"barn",
			"silo",
			"field",
			"pond",
			"tower",
			"barrel",
			"bucket",
			"gate",
			"fence",
			"wizard",
			"witch",
			"elf",
			"orc",
			"dwarf",
			"hobbit",
			"shrew"
		]);
		public static const ALLOWED_SITES:Vector.<String> = Vector.<String> ([
			"flickr.com",
			"photobucket.com"
		]);
		public static const BAD_URLS:Vector.<String> = Vector.<String> ([
			"photo_unavailable.gif"
		]);
		
		private const FULL_POINTS:int = 1000;
		private const MAX_ROUNDS:int = 5;
		private const MAX_CHOICES:int = 5;
		
		private const ORIG_WANDER:int = 200;
		private const ZOOM_TIME:Number = 15.0;

		private var rndImage:Bitmap;
		
		private var score:int;
		private var round:int;
		private var numCorrect:int;
		private var targetPoints:int;
		private var targetScore:int;
		private var pointStep:int;
		private var tempPoints:int;
		private var tempScore:int;
		private var potentialChoices:Vector.<String>;
		private var roundChoices:Vector.<String>;
		private var roundAnswer:String;
						
		protected var _imageRetriever:GoogleImageRetriever;
		
		private var imageURL:String;
		
		private var imageTween:TweenMax;
		
		private var gameOver:Boolean;
		private var roundOver:Boolean;
		private var imageLoading:Boolean;

		public function Game()
		{
			// Constructor
		}

		public function init():void
		{
			score = 0;
			round = 1;
			numCorrect = 0;
			
			hideStars();
			hideButtons();
			initButtons();
			initImageSearch();
			
			imageLoadingBar.visible = false;
			timerBar.visible = false;
			
			gameOverNotice.visible = false;
			correctNotice.visible = false;
			wrongNotice.visible = false;
			
			nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick);
			nextButton.visible = false;
			
			retryButton.addEventListener(MouseEvent.CLICK, onRetryButtonClick);
			retryButton.visible = false;
			
			imageButton.buttonMode = true;
			imageButton.mouseChildren = false;
			imageButton.addEventListener(MouseEvent.CLICK, onImageClick);
			imageButton.visible = false;
			
			startScreen.startButton.addEventListener(MouseEvent.CLICK, onStartButtonClick);
			
			updateStatUI();
			
			gameOver = true;
			
			Audio.musicPlay(WinningTheme, false);
		}
		
		private function hideStars():void 
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var star:Star = this.getChildByName("star" + (i + 1)) as Star;
				star.visible = false;
			}
		}
		
		private function showStars():void 
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var star:Star = this.getChildByName("star" + (i + 1)) as Star;
				star.visible = true;
			}
		}
		
		private function resetStars():void 
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var star:Star = this.getChildByName("star" + (i + 1)) as Star;
				star.gotoAndStop(1);
			}
		}
		
		private function hideButtons():void 
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
				choiceButton.visible = false;
			}
		}
		
		private function showButtons():void 
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
				choiceButton.visible = true;
			}
		}
		
		private function initButtons():void 
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
				choiceButton.buttonMode = true;
				choiceButton.mouseChildren = false;
				choiceButton.addEventListener(MouseEvent.CLICK, onChoiceButtonClick);
				choiceButton.addEventListener(MouseEvent.MOUSE_OVER, onChoiceButtonOver);
				choiceButton.addEventListener(MouseEvent.MOUSE_OUT, onChoiceButtonOut);
			}
		}
		
		private function resetButtons():void
		{
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
				choiceButton.gotoAndStop(1);
			}
		}
		
		private function initImageSearch():void 
		{
			// Image searching.

			_imageRetriever = new GoogleImageRetriever(new Vector.<String >   );
			_imageRetriever.imageType = GoogleImageType.PHOTO;
			_imageRetriever.size = GoogleImageSize.LARGE;
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.RETRIEVED, onImageReceived);
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.LOAD_FAILURE, onImageError);
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.LOAD_TIMEOUT, onImageError);
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.NO_RESULTS, onImageError);
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.SEARCH_FAILURE, onImageError);
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.SEARCH_TIMEOUT, onImageError);
			_imageRetriever.addEventListener(GoogleImageRetrieverEvent.ALL_RESULTS_SKIPPED, onImageError);
		}
		
		private function updateStatUI():void 
		{
			scoreText.text = "SCORE: " + score;
			roundText.text = "ROUND: " + round + " OF " + MAX_ROUNDS;
		}
		
		private function nextRound():void 
		{
			Audio.musicPlay(LoadingTheme);
			
			var star:Star = this.getChildByName("star" + round) as Star;
			star.gotoAndStop(4);
			
			resetButtons();
			correctNotice.visible = false;
			wrongNotice.visible = false;
			nextButton.visible = false;
			roundOver = false;
			
			TweenMax.to(timerBar, 0.01, {tint:0xFF6600});
			
			// Create our list of random keyword choices from our master list
			potentialChoices = new Vector.<String>();
			
			for each (var choice:String in MASTER_KEYWORDS)
			{
				potentialChoices.push(choice);			
			}
			
			// Now pick 5 unique keywords from that list to create our round list
			roundChoices = new Vector.<String>();
			
			for (var i:int = 0; i < MAX_CHOICES; i++)
			{
				var choiceIndex:int = Utils.rndInt(potentialChoices.length);
				choice = potentialChoices[choiceIndex];
				roundChoices.push(choice);
				potentialChoices.splice(choiceIndex,1);
				var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
				choiceButton.choiceText.text = choice.toUpperCase();
			}
						
			searchImage();
		}
		
		protected function searchImage():void {
			imageLoading = true;
			imageLoadingBar.visible = true;
			hideButtons();
			timerBar.visible = false;
			imageButton.visible = false;
			
			roundAnswer = ListUtil.getRandomItem(roundChoices);
			var query:String = "site:" + ListUtil.getRandomItem(ALLOWED_SITES) + " " + roundAnswer;
			_imageRetriever.search(query, Utils.rndInt(51));
			//trace("Searching image with query: " + query);
		}

		private function onImageReceived(e:GoogleImageRetrieverEvent):void
		{
			trace("Image received.");
			
			imageLoading = false;
			imageLoadingBar.visible = false;
			showButtons();
			
			timerBar.scaleX = 1.0;
			timerBar.visible = true;

			var ir:GoogleImageRetriever = _imageRetriever;
			if (ir.restrictedDomain || ! Tools.multipleStringMatch(ir.finalUrl,ALLOWED_SITES,BAD_URLS))
			{
				trace("Bad image. Loading other result.", ir.url);
				ir.skiplist.push(ir.url);
				ir.loadNextResult();
				return;
			}
			
			rndImage = ir.image;
			
			imageURL = ir.url;
			
			trace("Original image dimensions - width: " + rndImage.width + " x height: " + rndImage.height);
			
			var imageAspectRatio:Number = rndImage.width / rndImage.height;
			
			trace("Image Aspect Ratio: " + imageAspectRatio);
			
			var initialScaleFactor:Number = 960.0 / rndImage.height;
			
			trace("Initial scale factor: " + initialScaleFactor);
			
			var targetScaleFactor:Number = 96.0 / rndImage.height;
			
			trace("Target scale factor: " + targetScaleFactor);
			
			var targetWidth:Number = rndImage.width * targetScaleFactor;
			
			trace("Target width: " + targetWidth);
			
			rndImage.scaleX = initialScaleFactor;
			rndImage.scaleY = initialScaleFactor;			
			
			trace("New image dimensions - width: " + rndImage.width + " x height: " + rndImage.height);
			
			rndImage.x = Utils.rndSym(ORIG_WANDER) - (rndImage.width / 2.0);
			rndImage.y = Utils.rndSym(ORIG_WANDER) - (rndImage.height / 2.0);
			
			var widthDifference:Number = targetWidth - 96;
			var targetX:Number = 4 - (widthDifference / 2.0); 
			var targetY:Number = 4;
			
			imageContainer.addChild(rndImage);

			imageTween = TweenMax.to(rndImage, ZOOM_TIME, { scaleX:targetScaleFactor, scaleY:targetScaleFactor, x:targetX, y:targetY, ease:Sine.easeOut, onUpdate:onImageTweenUpdate, onComplete:onImageTweenComplete} ); 
			
			Audio.musicPlay(TimedTheme, false);
		}

		private function onImageError(e:GoogleImageRetrieverEvent):void
		{
			if ((e.type == GoogleImageRetrieverEvent.LOAD_FAILURE) || (e.type == GoogleImageRetrieverEvent.LOAD_TIMEOUT))
			{
				trace("Load error. Trying to load another result.", _imageRetriever.url);
				//_imageRetriever.abort();
				_imageRetriever.loadNextResult();
			}
			else if ((e.type == GoogleImageRetrieverEvent.SEARCH_FAILURE) || (e.type == GoogleImageRetrieverEvent.SEARCH_TIMEOUT))
			{
				trace("Search error. Trying to search again.");
				_imageRetriever.abort();
				_imageRetriever.retrySearch();
			}
			else if ((e.type == GoogleImageRetrieverEvent.NO_RESULTS) || (e.type == GoogleImageRetrieverEvent.ALL_RESULTS_SKIPPED))
			{
				trace("No results obtained. Searching again.");
				_imageRetriever.abort();
				searchImage();
			}
			else
			{
				trace("Something bad happened that I don't know what is.");
			}
		}
		
		private function onImageTweenUpdate():void 
		{
			timerBar.scaleX = 1.0 - imageTween.totalProgress;
			
			if (targetPoints > 0)
			{
				tempPoints += pointStep;
				
				if (tempPoints > targetPoints)
				{
					tempPoints = targetPoints;
				}
				
				correctNotice.pointsText.text = tempPoints.toString();
				
				tempScore += pointStep;
				
				if (tempScore > targetScore)
				{
					tempScore = targetScore;
				}
				
				scoreText.text = "SCORE: " + tempScore;
			}
		}
		
		private function onImageTweenComplete():void 
		{
			if (!roundOver)
			{
				Audio.musicPlay(LosingTheme, false);
				
				roundOver = true;
				
				nextButton.visible = true;
				
				imageButton.visible = true;
				
				wrongNotice.wrongText.text = "TIME'S UP - IT'S A " + roundAnswer.toUpperCase() + "/";
				wrongNotice.visible = true;
					
				var star:Star = this.getChildByName("star" + round) as Star;
				star.gotoAndStop(3);
				
				for (var i:int = 0; i < MAX_CHOICES; i++)
				{
					var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
					if (choiceButton.choiceText.text == roundAnswer.toUpperCase())
					{
						choiceButton.gotoAndStop(3);
						break;
					}
				}
			}
			else
			{
				if (targetScore > 0)
				{
					score = targetScore;
				}
				
				correctNotice.pointsText.text = targetPoints.toString();
				updateStatUI();
			}
		}		

		private function onChoiceButtonClick(e:MouseEvent):void
		{
			if (!(gameOver || roundOver))
			{
				roundOver = true;
				
				nextButton.visible = true;
				
				imageButton.visible = true;
				
				if (e.target.choiceText.text.toLowerCase() == roundAnswer)
				{
					Audio.musicPlay(WinningTheme, false);
					
					numCorrect++;
					
					var star:Star = this.getChildByName("star" + round) as Star;
					star.gotoAndStop(2);
					
					var points:int = FULL_POINTS * (1.0 - imageTween.totalProgress);
					targetPoints = points;
					targetScore = score + points;
					pointStep = 50;
					tempScore = score;
					tempPoints = 0;
					
					correctNotice.pointsText.text = tempPoints.toString();
					correctNotice.visible = true;
					
					e.target.gotoAndStop(3);
					
					TweenMax.to(timerBar, 0.01, {tint:0x006600});
				}
				else
				{
					Audio.musicPlay(LosingTheme, false);
					
					wrongNotice.wrongText.text = "NOPE - IT'S A " + roundAnswer.toUpperCase() + "/";
					wrongNotice.visible = true;
					
					targetPoints = 0;
					targetScore = 0;
					pointStep = 0;
					
					e.target.gotoAndStop(4);
					
					star = this.getChildByName("star" + round) as Star;
					star.gotoAndStop(3);
					
					TweenMax.to(timerBar, 0.01, {tint:0x990000});
					
					for (var i:int = 0; i < MAX_CHOICES; i++)
					{
						var choiceButton:ChoiceButton = this.getChildByName("choice" + (i + 1)) as ChoiceButton;
						if (choiceButton.choiceText.text == roundAnswer.toUpperCase())
						{
							choiceButton.gotoAndStop(3);
							break;
						}
					}
				}
				
				imageTween.timeScale = 20.0;
			}
		}
		
		private function onChoiceButtonOver(e:MouseEvent):void
		{
			if (!roundOver)
			{
				e.target.gotoAndStop(2);
			}
		}
		
		private function onChoiceButtonOut(e:MouseEvent):void
		{
			if (!roundOver)
			{
				e.target.gotoAndStop(1);
			}
		}
		
		private function onStartButtonClick(e:MouseEvent):void
		{
			startScreen.visible = false;
			showStars();
			gameOver = false;
			nextRound();
		}
		
		private function onNextButtonClick(e:MouseEvent):void
		{
			imageTween.kill();
			imageContainer.removeChild(rndImage);
			
			if (round == MAX_ROUNDS)
			{
				updateStatUI();
				setGameOver();				
			}
			else
			{
				round++;
				updateStatUI();
				nextRound();
			}
		}
		
		private function onRetryButtonClick(e:MouseEvent):void
		{
			score = 0;
			round = 1;
			numCorrect = 0;
			
			updateStatUI();
			
			retryButton.visible = false;
			
			gameOverNotice.visible = false;
			
			gameOver = false;
			
			resetStars();
				
			nextRound();
		}
		
		private function onImageClick(e:MouseEvent):void
		{
			Utils.openURL(imageURL);
		}
		
		private function setGameOver():void 
		{
			Audio.musicPlay(WinningTheme, false);
			
			gameOver = true;
			hideButtons();
			timerBar.visible = false;
			
			correctNotice.visible = false;
			wrongNotice.visible = false;
			gameOverNotice.visible = true;
			
			nextButton.visible = false;
			retryButton.visible = true;
		}
	}
}