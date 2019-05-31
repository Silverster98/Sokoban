using System;
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

namespace Sokoban
{
    /// <summary>
    /// Page1.xaml 的交互逻辑
    /// </summary>
    public partial class SelectPage : Page
    {
        public int number;
        public SelectPage()
        {
            number = 0;
            InitializeComponent();
        }
        private void Button_StartGame1_Click(object sender, RoutedEventArgs e)
        {
            number = 1;
            Page gamePage = new GamePage(number);
            this.NavigationService.Navigate(gamePage);
        }
        private void Button_StartGame2_Click(object sender, RoutedEventArgs e)
        {
            number = 2;
            Page gamePage = new GamePage(number);
            this.NavigationService.Navigate(gamePage);
        }
        private void Button_StartGame3_Click(object sender, RoutedEventArgs e)
        {
            number = 3;
            Page gamePage = new GamePage(number);
            this.NavigationService.Navigate(gamePage);
        }
        private void Button_StartGame4_Click(object sender, RoutedEventArgs e)
        {
            number = 4;
            Page gamePage = new GamePage(number);
            this.NavigationService.Navigate(gamePage);
        }
        private void Button_StartGame5_Click(object sender, RoutedEventArgs e)
        {
            number = 5;
            Page gamePage = new GamePage(number);
            this.NavigationService.Navigate(gamePage);
        }
    }
}
