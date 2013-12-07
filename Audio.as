package
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.events.TimerEvent;	
	
	public class Audio
	{
		/**
		 * Controls the volume of both sound effects and music, a value from 0 to 1.
		 */
		public static var volume:Number = 1;
		
		/**
		 * Controls the volume of sound effects, a value from 0 to 1.
		 */
		public static var soundVolume:Number = 1;
		
		/**
		 * If sound effects and music should both be muted.
		 */
		public static var mute:Boolean = false;
		
		/**
		 * If sound effects should be muted.
		 */
		public static var soundMute:Boolean = false;
		
		/**
		 * Controls the volume of music, a value from 0 to 1.
		 */
		public static function get musicVolume():Number
		{
			return _musicVolume;
		}
		public static function set musicVolume(value:Number):void
		{
			var mute:Number = (_musicMute ? 0 : 1);
			_musicVolume = value < 0 ? 0 : value;
			_musicTR.volume = _musicVolume * mute;
			if (_musicCH) _musicCH.soundTransform = _musicTR;
		}
		
		/**
		 * If music should be muted.
		 */
		public static function get musicMute():Boolean
		{
			return _musicMute;
		}
		public static function set musicMute(value:Boolean):void
		{
			var mute:Number = (value ? 0 : 1);
			_musicMute = value;
			_musicTR.volume = _musicVolume * mute;
			if (_playing) _musicCH.soundTransform = _musicTR;
		}
		
		/**
		 * Plays a sound effect.
		 * @param	sound	The embedded Sound class to play.
		 * @param	vol		The volume factor, a value from 0 to 1.
		 * @param	pan		The panning factor, from -1 (left speaker) to 1 (right speaker).
		 */
		public static function play(sound:Class, vol:Number = 1, pan:Number = 0):void
		{
			if (mute || soundMute) return;
			var id:int = _soundID[String(sound)];
			if (!id)
			{
				_soundID[String(sound)] = id = _id;
				_sound[_id ++] = new sound();
			}
			_soundTR.volume = vol * soundVolume * volume;
			_soundTR.pan = pan;
			_sound[id].play(0, 0, _soundTR);
		}
		
		/**
		 * Plays the sound as a music track.
		 * @param	sound	The embedded Sound class to play.
		 * @param	loop	Whether the track should loop or not.
		 * @param	end		An optional function to call when the track finishes or loops.
		 */
		public static function musicPlay(sound:Class, loop:Boolean = true, end:Function = null):void
		{
			musicStop();
			_music = new sound();
			var mute:Number = (musicMute ? 0 : 1);
			_musicTR.volume = _musicVolume * volume * mute;

			if (_mp3) {	// are we using mp3s for our soundtrack?
				_position = _mp3Leader;
				if (loop) { // are we going to loop the mp3?
					_mp3PlaceToStop = _music.length - _mp3Follower;
					_musicCH = _music.play(_position, 0, _musicTR);
					if (!_mp3Timer) {
						_mp3Timer = new Timer(1);	// create 1ms timer (in reality this will run slower based on FPS)
					}
					if (!_mp3Timer.hasEventListener(TimerEvent.TIMER)) {
						_mp3Timer.addEventListener(TimerEvent.TIMER, mp3TimerListener);
					}
					_mp3Timer.start();
				} else { // if not, then just play once and start our end listener
					_musicCH = _music.play(_position, 0, _musicTR);
					_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
				}
			} else { // wav data
				_position = 0;
				_musicCH = _music.play(_position, loop ? 999 : 0, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			}
			_playing = true;
			_looping = loop;
			_paused = false;
			_end = end;
		}
		
		/**
		 * Stops the music track (will not trigger the end-sound function).
		 */
		public static function musicStop():void
		{
			if (!_playing) return;

			if (_musicCH.hasEventListener(Event.SOUND_COMPLETE)) { 
				_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false); 
			}
			
			if (_mp3Timer) {
				_mp3Timer.stop();
				if (_mp3Timer.hasEventListener(TimerEvent.TIMER)) {
					_mp3Timer.removeEventListener(TimerEvent.TIMER, mp3TimerListener);		
				}
			}

			_musicCH.stop();
			_playing = _paused = false;
		}
		
		/**
		 * Pauses the music track (will not trigger the end-sound function).
		 */
		public static function musicPause():void
		{
			if (_playing && !_paused)
			{
				_position = _musicCH.position;
				
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE)) {
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				}
				
				if (_mp3Timer) {
					_mp3Timer.stop();
					if (_mp3Timer.hasEventListener(TimerEvent.TIMER)) {
						_mp3Timer.removeEventListener(TimerEvent.TIMER, mp3TimerListener);		
					}
				}
				
				_musicCH.stop();
				_playing = false;
				_paused = true;
			}
		}
		
		/**
		 * Resumes the music track from the position at which it was paused.
		 */
		public static function musicResume():void
		{
			if (_paused)
			{
				if (_mp3) {	// are we using mp3s for our soundtrack?
					if (_looping) { // are we going to loop the mp3?
						_musicCH = _music.play(_position, 0, _musicTR);
						if (!_mp3Timer) {
							_mp3Timer = new Timer(1);	// create 1ms timer (in reality this will run slower based on FPS)
						}
						if (!_mp3Timer.hasEventListener(TimerEvent.TIMER)) {
							_mp3Timer.addEventListener(TimerEvent.TIMER, mp3TimerListener);
						}						
						_mp3Timer.reset();
						_mp3Timer.start();
					} else { // if not, then just continue to play once and start our end listener
						_musicCH = _music.play(_position, 0, _musicTR);
						_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
					}
				} else { // wav data
					_musicCH = _music.play(_position, _looping ? 999 : 0, _musicTR);
					_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
				}
				
				_playing = true;
				_paused = false;
			}
		}
		
		// function for the end-sound soundEvent to trigger (only called by WAVs and non-looping mp3s)
		private static function musicEnd(e:Event):void
		{
			if (_looping) {
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE)) {
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				}
				_musicCH = _music.play(0, 999, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			} else {
				_playing = false;
				_paused = false;
				_position = (_mp3 ? _mp3Leader : 0);
			}
		
			if (_end !== null) _end();
		}
		
		// function to monitor looping mp3s and to restart them soon enough to skip end padding
		// and start them after beginning padding
		private static function mp3TimerListener(e:TimerEvent):void {
			if (_musicCH.position > _mp3PlaceToStop) { 
				_musicCH.stop();
				_position = _mp3Leader;
				_musicCH = _music.play(_position, 0, _musicTR);
			}
		}
		
		// variables for playing sounds/music
		private static var _id:int = 0;
		private static var _soundID:Array = [];
		private static var _sound:Vector.<Sound> = new Vector.<Sound>();
		private static var _soundTR:SoundTransform = new SoundTransform();
		private static var _music:Sound;
		private static var _musicTR:SoundTransform = new SoundTransform();
		private static var _musicCH:SoundChannel;
		private static var _playing:Boolean = false;
		private static var _looping:Boolean = false;
		private static var _paused:Boolean = false;
		private static var _position:Number = 0;
		private static var _musicVolume:Number = 1;
		private static var _musicMute:Boolean = false;
		private static var _end:Function = null;
		
		// mp3 related (added by me)
		private static var _mp3:Boolean = true;
		private static var _mp3Leader:int = 50;			// ms defaults for beta audacity 
		private static var _mp3Follower:int = 235;		// ms defaults for beta audacity 
		private static var _mp3PlaceToStop:int;			// ms defaults for beta audacity
		private static var _mp3Timer:Timer = null;		// holds 1ms timer to monitor mp3s

	}
}