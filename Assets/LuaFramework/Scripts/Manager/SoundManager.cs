using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace LuaFramework {
    public class SoundManager : Manager {
        private AudioSource audio;
        private Hashtable sounds = new Hashtable();
		private float sound_volume = 1.0f;
        void Start() {
            audio = GetComponent<AudioSource>();
			if (audio == null) {
				audio = gameObject.AddComponent<AudioSource>();
			}
        }

        /// <summary>
        /// 添加一个声音
        /// </summary>
        void Add(string key, AudioClip value) {
            if (sounds[key] != null || value == null) return;
            sounds.Add(key, value);
        }

        /// <summary>
        /// 获取一个声音
        /// </summary>
        AudioClip Get(string key) {
            if (sounds[key] == null) return null;
            return sounds[key] as AudioClip;
        }

        /// <summary>
        /// 载入一个音频
        /// </summary>
        public AudioClip LoadAudioClip(string path) {
            AudioClip ac = Get(path);
            if (ac == null) {
                ac = (AudioClip)Resources.Load(path, typeof(AudioClip));
                Add(path, ac);
            }
            return ac;
        }

        /// <summary>
        /// 是否播放背景音乐，默认是1：播放
        /// </summary>
        /// <returns></returns>
        public bool CanPlayBackSound() {
            string key = AppConst.AppPrefix + "BackSound";
            int i = PlayerPrefs.GetInt(key, 1);
            return i == 1;
        }

        /// <summary>
        /// 播放背景音乐
        /// </summary>
        /// <param name="canPlay"></param>
        public void PlayBacksound(string name, bool canPlay) {
            if (audio.clip != null) {
                if (name.IndexOf(audio.clip.name) > -1) {
                    if (!canPlay) {
                        audio.Stop();
                        audio.clip = null;
                        Util.ClearMemory();
                    }
                    return;
                }
            }
            if (canPlay) {
                audio.loop = true;
                audio.clip = LoadAudioClip(name);
                audio.Play();
            } else {
                audio.Stop();
                audio.clip = null;
                Util.ClearMemory();
            }
        }

        /// <summary>
        /// 是否播放音效,默认是1：播放
        /// </summary>
        /// <returns></returns>
        public bool CanPlaySoundEffect() {
            string key = AppConst.AppPrefix + "SoundEffect";
            int i = PlayerPrefs.GetInt(key, 1);
            return i == 1;
        }

        /// <summary>
        /// 播放音频剪辑
        /// </summary>
        /// <param name="clip"></param>
        /// <param name="position"></param>
        public void Play(AudioClip clip, Vector3 position) {
            if (!CanPlaySoundEffect()) return;
			AudioSource.PlayClipAtPoint(clip, position, sound_volume);
        }

        /// <summary>
        /// 播放音频剪辑
        /// </summary>
        /// <param name="path"></param>
        public void PlaySound(string path) {
            if (!CanPlaySoundEffect()) return;
            if (sounds[path] == null)
            {
                LoadAudioClip(path);
            }
			AudioSource.PlayClipAtPoint(sounds[path] as AudioClip, Vector3.zero, sound_volume);
        }

        /// <summary>
        /// 设置背景音乐大小
        /// </summary>
        /// <param name="volume"></param>
		public void SetBacksoundVolume(float volume){
            audio.volume = volume;
        }

		/// <summary>
		/// 设置音效大小
		/// </summary>
		/// <param name="volume"></param>
		public void SetSoundVolume(float volume){
			sound_volume = volume;
		}
    }
}