﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Runtime.InteropServices;

namespace Sokoban
{
    /// <summary>
    /// GamePage.xaml 的交互逻辑
    /// </summary>
    /// 

    public partial class GamePage : Page
    {
        [DllImport("C:/Users/罗楠/source/repos/Sokoban/asm_kernel/asm.dll")]
        public static extern void loadMap(int count, byte[] now);

        [DllImport("C:/Users/罗楠/source/repos/Sokoban/asm_kernel/asm.dll")]
        public static extern int moveRight(byte[] now);

        [DllImport("C:/Users/罗楠/source/repos/Sokoban/asm_kernel/asm.dll")]
        public static extern int moveLeft(byte[] now);

        [DllImport("C:/Users/罗楠/source/repos/Sokoban/asm_kernel/asm.dll")]
        public static extern int moveUp(byte[] now);

        [DllImport("C:/Users/罗楠/source/repos/Sokoban/asm_kernel/asm.dll")]
        public static extern int moveDown(byte[] now);

        public int Level;
        public int Status;
        public int StepsCount;
        public int Time = 0;

        // 新数组和老数组
        byte[] currentArray = new byte[64];
        byte[] copyArray = new byte[64];

        Dictionary<int, string> mapElementParams = new Dictionary<int, string>()
        {
            {98,"box.png"},
            {100, "target.png"},
            {101,"road.png"},
            {111,"box.png"},
            {112,"people.png"},
            {116,"people.png"},
            {119,"wall.png"}
        };

        public GamePage(int level)
        {
            Level = level;
            InitializeComponent();
            InitGame(level);
        }
        // 监听键盘输入
        private void Page_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            Status = 0;
            if (e.Key == Key.Up || e.Key == Key.W)
            {
                AddStepsCount();

                //保留老数组函数
                Copy(copyArray, currentArray);

                int Status = moveUp(currentArray);
                UpdateGameUI(currentArray, copyArray);

                if (Status == 1) //结束游戏
                {
                    if (Level == 5)
                    {
                        Page clearPage = new ClearPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(clearPage);
                    }
                    else
                    {
                        Page passPage = new PassPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(passPage);
                    }
                }
            }
            else if (e.Key == Key.Down || e.Key == Key.S)
            {
                AddStepsCount();

                //保留老数组函数
                Copy(copyArray, currentArray);

                int Status = moveDown(currentArray);
                UpdateGameUI(currentArray, copyArray);

                if (Status == 1) //结束游戏
                {
                    if (Level == 5)
                    {
                        Page clearPage = new ClearPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(clearPage);
                    }
                    else
                    {
                        Page passPage = new PassPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(passPage);
                    }
                }
            }
            else if (e.Key == Key.Left || e.Key == Key.A)
            {
                AddStepsCount();

                //保留老数组函数
                Copy(copyArray, currentArray);

                int Status = moveLeft(currentArray);
                UpdateGameUI(currentArray, copyArray);

                if (Status == 1) //结束游戏
                {
                    if (Level == 5)
                    {
                        Page clearPage = new ClearPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(clearPage);
                    }
                    else
                    {
                        Page passPage = new PassPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(passPage);
                    }
                }

            }
            else if (e.Key == Key.Right || e.Key == Key.D)
            {
                AddStepsCount();
         
                //保留老数组函数
                Copy(copyArray, currentArray);

                int Status = moveRight(currentArray);
                UpdateGameUI(currentArray, copyArray);

                if (Status == 1) //结束游戏
                {
                    if (Level == 5)
                    {
                        Page clearPage = new ClearPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(clearPage);
                    }
                    else
                    {
                        Page passPage = new PassPage(Level, Time, StepsCount);
                        this.NavigationService.Navigate(passPage);
                    }
                }

            }

        }


        //给位置，给新的元素，画图
        public void DrawUI(int i, byte item)
        {
            string path = "resource/";
            path += mapElementParams[item];

            if (path.Equals("resource/"))
            {
                MessageBox.Show("判断数组失败 drawUI function");
            }

            string imgName = "i" + i.ToString();
            var img = (Image)this.FindName(imgName);
            img.Source = new BitmapImage(new Uri(path, UriKind.Relative));
        }


        //调用函数，给出两个数组，对比重绘
        public void UpdateGameUI(byte[] currentArray, byte[] copyArray)
        {
            for (int i = 0; i < 64; i++)
            {
                if (copyArray[i] == currentArray[i])
                {
                    continue;
                }
                else
                {
                    DrawUI(i, currentArray[i]);
                }
            }
        }

        private void Back2Page_Button_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Back2Page_Button_Click pressed.");

        }

        private void Start_Button_Click(object sender, RoutedEventArgs e)
        {
            InitGame(Level);
            showSteps.Text = StepsCount.ToString();
        }

        public void AddStepsCount()
        {
            StepsCount++;
            showSteps.Text = StepsCount.ToString();
        }
     
        public void InitGame(int level)
        {
            Status = 0;
            StepsCount = 0;

            loadMap(level - 1, currentArray);

            for (int i = 0; i < 64; i++)
            {
                DrawUI(i, currentArray[i]);
            }
        }

        public void Copy(byte[] copyArray, byte[] currentArray)
        {
            for(int i = 0; i <  64; i++)
            {
                copyArray[i] = currentArray[i];
            }
        }
    }
}
