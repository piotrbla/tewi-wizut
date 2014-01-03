using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace ForexTester
{
    partial class Tester
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea1 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            this.btnLoadFile = new System.Windows.Forms.Button();
            this.chart1 = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.lblStatus = new System.Windows.Forms.Label();
            this.chkMatlab = new System.Windows.Forms.CheckBox();
            this.cmbFiles = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.txtStatus = new System.Windows.Forms.TextBox();
            this.chkDrawReturns = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).BeginInit();
            this.SuspendLayout();
            // 
            // btnLoadFile
            // 
            this.btnLoadFile.Location = new System.Drawing.Point(53, 59);
            this.btnLoadFile.Name = "btnLoadFile";
            this.btnLoadFile.Size = new System.Drawing.Size(75, 23);
            this.btnLoadFile.TabIndex = 0;
            this.btnLoadFile.Text = "Load file";
            this.btnLoadFile.UseVisualStyleBackColor = true;
            this.btnLoadFile.Click += new System.EventHandler(this.Button1Click);
            // 
            // chart1
            // 
            chartArea1.AxisY.IsStartedFromZero = false;
            chartArea1.Name = "ChartArea1";
            this.chart1.ChartAreas.Add(chartArea1);
            this.chart1.Location = new System.Drawing.Point(14, 436);
            this.chart1.Name = "chart1";
            this.chart1.Size = new System.Drawing.Size(1869, 619);
            this.chart1.TabIndex = 1;
            this.chart1.Text = "chart1";
            // 
            // lblStatus
            // 
            this.lblStatus.AutoSize = true;
            this.lblStatus.Location = new System.Drawing.Point(291, 9);
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Size = new System.Drawing.Size(40, 13);
            this.lblStatus.TabIndex = 2;
            this.lblStatus.Text = "Status:";
            // 
            // chkMatlab
            // 
            this.chkMatlab.AutoSize = true;
            this.chkMatlab.Checked = true;
            this.chkMatlab.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkMatlab.Location = new System.Drawing.Point(53, 36);
            this.chkMatlab.Name = "chkMatlab";
            this.chkMatlab.Size = new System.Drawing.Size(110, 17);
            this.chkMatlab.TabIndex = 3;
            this.chkMatlab.Text = "Convert to Matlab";
            this.chkMatlab.UseVisualStyleBackColor = true;
            // 
            // cmbFiles
            // 
            this.cmbFiles.FormattingEnabled = true;
            this.cmbFiles.Location = new System.Drawing.Point(53, 9);
            this.cmbFiles.Name = "cmbFiles";
            this.cmbFiles.Size = new System.Drawing.Size(141, 21);
            this.cmbFiles.TabIndex = 4;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(9, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(38, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "Walor:";
            // 
            // txtStatus
            // 
            this.txtStatus.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.txtStatus.Location = new System.Drawing.Point(14, 99);
            this.txtStatus.Multiline = true;
            this.txtStatus.Name = "txtStatus";
            this.txtStatus.Size = new System.Drawing.Size(1763, 331);
            this.txtStatus.TabIndex = 6;
            // 
            // chkDrawReturns
            // 
            this.chkDrawReturns.AutoSize = true;
            this.chkDrawReturns.Checked = true;
            this.chkDrawReturns.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkDrawReturns.Location = new System.Drawing.Point(202, 36);
            this.chkDrawReturns.Name = "chkDrawReturns";
            this.chkDrawReturns.Size = new System.Drawing.Size(126, 17);
            this.chkDrawReturns.TabIndex = 7;
            this.chkDrawReturns.Text = "Draw strategy returns";
            this.chkDrawReturns.UseVisualStyleBackColor = true;
            // 
            // Tester
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1895, 1067);
            this.Controls.Add(this.chkDrawReturns);
            this.Controls.Add(this.txtStatus);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.cmbFiles);
            this.Controls.Add(this.chkMatlab);
            this.Controls.Add(this.lblStatus);
            this.Controls.Add(this.chart1);
            this.Controls.Add(this.btnLoadFile);
            this.Name = "Tester";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "ForexTester";
            this.Load += new System.EventHandler(this.Form1Load);
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnLoadFile;
        private System.Windows.Forms.DataVisualization.Charting.Chart chart1;
        private System.Windows.Forms.Label lblStatus;
        private System.Windows.Forms.CheckBox chkMatlab;
        private System.Windows.Forms.ComboBox cmbFiles;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtStatus;
        private System.Windows.Forms.CheckBox chkDrawReturns;
    }
}

