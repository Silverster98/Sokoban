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
    /// Page2.xaml 的交互逻辑
    /// </summary>
    public partial class ClearPage : Page
    {
        public int number, time, step;
        public ClearPage(int value_number, int value_time, int value_step)
        {
            number = value_number;
            time = value_time;
            step = value_step;
            InitializeComponent();
            showTime.DataContext = time;
            showStep.DataContext = step;
        }
        private void Button_Regame_Click(object sender, RoutedEventArgs e)
        {
            Page gamePage = new GamePage(number);
            this.NavigationService.Navigate(gamePage);
        }
        private void Button_Select_Click(object sender, RoutedEventArgs e)
        {
            Page selectPage = new SelectPage();
            this.NavigationService.Navigate(selectPage);
        }
    }
}
