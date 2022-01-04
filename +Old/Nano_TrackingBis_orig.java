//Version 1
//===================================================
// Name changed from Nano_Track.java to Nano_Tracking.java
//  to illustrate that in this version the processing steps of the 
//   correlation are actually calculated.
//   
//      There is a few commented lines that one can uncomment to see
//       how the correlation function looks like. 
//
//      Modified by Nicolas Biais <nb2200@columbia.edu> 7/2005
//====================================================

//Version 0
//===========================================================================
// Nano_Track.java
//
// Track a kernel across a stack of images using cross-correlation.
//
// Algorithm taken from "Tracking kinesin-driven movements with
// nanometre-scale precision" by Jeff Gelles, Bruce J. Schnapp and Michael
// P. Sheetz.
//
// Based initially on Cell_Outliner plugin for ImageJ by mike castleman 
// <mlc67@columbia.edu>
// 
// Written by Blaine Boman <bgb10@columbia.edu> 7/2003.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//===========================================================================
import ij.*;
import ij.io.*;
import ij.gui.*;
import ij.plugin.frame.PlugInFrame;
import ij.process.*;
import ij.plugin.*;

import java.io.*;
import java.util.Hashtable;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;


/**
   Nano Tracking plugin for ImageJ

  **/
public class Nano_TrackingBis_orig
	extends PlugInFrame
{
	private PlugInFrame thisFrame;
	private ImagePlus mainImage;
	private ImagePlus kernelImage;
       private ImagePlus test;
	private ImageStack imgStack;
	private Roi roi;
       private Window win;
	private int kernScaleTerm = 0;

	private JButton stopItButton;
	private JButton saveKernelButton;
	private JSlider sliceSlider;
	private JLabel currRoiLabel1;
	private JLabel kernelViewer;
	private JLabel currSliceLabel;
	private JTextField startSliceLabel;
	private JTextField endSliceLabel;
	private JProgressBar progBar;

	private boolean stepThrough;
	private boolean stopThread;
	private Thread runThread;


	/* constructor */
	public Nano_TrackingBis_orig()
	{
		super("NanoTrackingBis");

		initialize();
	}


	/* set up the main image stack and roi, then create the window */
	private void initialize()
	{
		mainImage = WindowManager.getCurrentImage();
		if(mainImage == null)
		{
			JOptionPane.showMessageDialog(this, 
					"Please open an image stack before starting " + 
					" the plugin.", "Error",
					JOptionPane.ERROR_MESSAGE);
			return;
		}

		imgStack = mainImage.getStack();
		if (imgStack == null) 
		{
			JOptionPane.showMessageDialog(this,
					"This plugin only works on image stacks.",
					"Error", JOptionPane.ERROR_MESSAGE);
			return;
		}

		roi = mainImage.getRoi();
		if (roi == null) 
		{
			roi = new Roi(0, 0, mainImage);
			mainImage.setRoi(roi);
		}

		createWindow();
	}


	/* when switching back to the plugin, we need to check to make sure
	   we are still working on the same stack as before.  if the image
	   has changed, we need to update the plugin to use the new image. */
	public void windowActivated(WindowEvent e) 
	{
		super.windowActivated(e);

		/* re-initialize if the current image has changed */
		if (WindowManager.getCurrentImage() != mainImage) 
		{
			mainImage = WindowManager.getCurrentImage();
			updateWindow();
		}
    }


	/* if the image changed, we need to update a few of the GUI components */
	private void updateWindow()
	{
		updateSliceLabel();

		startSliceLabel.setText("1");
		endSliceLabel.setText(Integer.toString(mainImage.getStackSize()));
		setNewRoi();
	}


	/* load a kernel image from disk */
	private void loadKernel()
	{
		OpenDialog od = new OpenDialog("Load Kernel Image", "");
		
		if(od.getFileName() != null)
		{
			String filename = od.getFileName();
			
			ImagePlus newKernelImage = new ImagePlus(filename);			
			
			if(newKernelImage.getImage() == null)
			{
				JOptionPane.showMessageDialog(thisFrame, 
						"Invalid kernel image", "Error",
						JOptionPane.ERROR_MESSAGE);
				return;
			}
			
			if(newKernelImage.getStack().getSize() > 1) 
			{
				JOptionPane.showMessageDialog(thisFrame, 
						"The kernel must be a single image, " + 
						"not a stack.", "Error",
						JOptionPane.ERROR_MESSAGE);
				return;
			}
			
			kernelImage  = newKernelImage;
			updateKernelImage();
		}
	}


	/* grab a kernel image from the currently defined ROI */
	private void grabKernel()
	{
		ImageProcessor imgProc = mainImage.getProcessor();
		ImageProcessor kernelCrop = imgProc.crop();
		kernelImage = new ImagePlus("kernel", kernelCrop);
		updateKernelImage();
	}


	/* save the currently loaded kernel image to disk */
	private void saveKernel()
	{
		SaveDialog sd = new SaveDialog("Save Kernel As..",
				"kernel.tif", ".tif");
		
		if(sd.getFileName() != null)
		{
			FileSaver fileSaver = new FileSaver(kernelImage);
			fileSaver.saveAsTiff(sd.getFileName());
		}
		else
		{
			JOptionPane.showMessageDialog(thisFrame, 
					"Kernel not saved.  No filename specified.",
					"Error", JOptionPane.ERROR_MESSAGE);
		}
	}
	

	/* set a new roi based on the current selection */
	private void setNewRoi()
	{
		roi = mainImage.getRoi();
		if (roi == null) 
		{
			roi = new Roi(0, 0, mainImage);
			mainImage.setRoi(roi);
		}
		
		currRoiLabel1.setText(getRoiString());	   
	}


	/* recurse through the given container, disabling/enabling all of the
	   children components */
	private void setContainerEnabled(Container c, boolean enable)
	{
		Component[] components = c.getComponents();
		for(int i=0; i<components.length; i++) 
		{
			components[i].setEnabled(enable);
			if(components[i] instanceof Container) 
			{
				setContainerEnabled((Container)components[i], enable);
			}
		}
	}


	/* if the cross-correlation is running, we want to disable most of the
	   gui controls (and reenable them when it is done). */
	private void toggleGuiEnabled(boolean enable)
	{
		boolean stop = stopItButton.isEnabled();		
		
		setContainerEnabled(this, enable);
		if(kernelImage != null)
		{
			saveKernelButton.setEnabled(enable);
		}		
		progBar.setEnabled(true);
	}


	/*  returns the bounds of the current roi as a string i.e.:
	   "(x1, y1) to (x2, y2)" */
	private String getRoiString()
	{
		Rectangle roiRect = roi.getBounds();
		return new String("(" + (int)roiRect.getX() + ", " +
				(int)roiRect.getY() + ")" + " to " + "(" + 
				(int)(roiRect.getX() + roiRect.getWidth()) + ", " + 
				(int)(roiRect.getY() + roiRect.getHeight()) + ")");
	}


	/* controller method for the cross correlation.
	   steps through the appropiate slices and calls processCurrentSlice() to
	   actually perform the crossCorrelation on the slice. 	*/
	private void runCrossCorrelation()
	{
		int loopStart = (new Integer(startSliceLabel.getText())).intValue();
		int loopEnd = (new Integer(endSliceLabel.getText())).intValue();

		stopItButton.setEnabled(true);

		/* make sure we have a kernel loaded */
		if(kernelImage == null)
		{
			JOptionPane.showMessageDialog(thisFrame, 
					"Please load a kernel image first.", "Error",
					JOptionPane.ERROR_MESSAGE);
			return;
		}

		progBar.setMinimum(loopStart);
		progBar.setMaximum(loopEnd);
		progBar.setStringPainted(false);

		/* not stepping, we are going through them all */
		if(!stepThrough)
		{
			for(int i=loopStart; i<= loopEnd; i++)
			{
				mainImage.setSlice(i);
				progBar.setValue(i);
				processCurrentSlice();

				/* user pressed the stop button */
				if(stopThread)
				{
					crossCorrDone();
					JOptionPane.showMessageDialog(this,
							"Cross-correlation stopped.");
					return;
				}
			}
			
			JOptionPane.showMessageDialog(this, "Cross-correlation finished");
		}
		/* stepping, so only process one slice */
		else
		{
			int currSlice = mainImage.getCurrentSlice();
			mainImage.setSlice(currSlice + 1);
			processCurrentSlice();
			updateSliceLabel();
		}

		crossCorrDone();
	}


	/* called when the cross correlation either finishes naturally, or the user
	   pushes the stop button to stop it.  just sets the GUI back to it's
	   non-running state. */
	private void crossCorrDone()
	{
		progBar.setStringPainted(true);
		progBar.setValue(0);
		progBar.setString("not running");
		toggleGuiEnabled(true);
		stopItButton.setEnabled(false);
	}


	/* here the actual cross-correlation is performed on the current slice
	   of the image stack. */
	private void processCurrentSlice()
	{
		/* lock up the images within ImageJ for this thread */
		mainImage.lock();
		kernelImage.lock();

		Rectangle rect = roi.getBounds();
		ImageProcessor imgProc = imgStack.getProcessor(
				mainImage.getCurrentSlice());
		ImageProcessor kernProc = kernelImage.getProcessor();
		int kernWidth = kernProc.getWidth();
		int kernHeight = kernProc.getHeight();
              int ACWidth = rect.width - kernWidth;
              int ACHeight = rect.height - kernHeight;
             int[][] vals = new int[ACWidth][ACHeight];             

		/* step through the ROI using idices i_x and i_y (image_x, image_y) */
		int yLoop = rect.y+ACHeight;
		int xLoop = rect.x+ACWidth;
		for(int imgY=rect.y; imgY < yLoop; imgY++)
		{
			for(int imgX=rect.x; imgX < xLoop; imgX++)
			{
				int crossCorrVal = 0;
				/* step through the kernel, using k_x and k_y*/
                           
				for(int kernY=0; 
					kernY < kernHeight; kernY++)
				{
					for(int kernX=0; 
						kernX < kernWidth; kernX++)
					{					   
							crossCorrVal += imgProc.getPixel(imgX+kernX, 
									imgY+kernY)*(kernProc.getPixel(kernX,kernY)-kernScaleTerm);
					}
				}
				vals[imgX-rect.x][imgY-rect.y] = crossCorrVal;
			}
		}		

             /* compute some numbesr eventually useful for setting the threshold*/ 
             float Moyenne= 0;
             float Quadra = 0;

             for(int j=0; j < ACHeight; j++)
		{
			for(int i=0; i < ACWidth; i++)
			{
                        Moyenne += vals[i][j];

                     }
              }
              
              for(int j=0; j < ACHeight; j++)
		{
			for(int i=0; i < ACWidth; i++)
			{
                         Quadra += (vals[i][j]-Moyenne/(rect.width*rect.height))*(vals[i][j]-Moyenne/(rect.width*rect.height));
                     }
              }


             /* find the maximum in cross-correlation matrix */
		int maxI = 0;
		int maxJ = 0;
		for(int i=0; i<vals.length; i++)
		{
			for(int j=0; j<vals[i].length; j++)
			{
				if(vals[i][j] > vals[maxI][maxJ])
				{
					maxI = i;
					maxJ = j;
				}
			}
		}
                     
              /* find the minimum in cross-correlation matrix */
		int minI = 0;
		int minJ = 0;
		for(int i=0; i<vals.length; i++)
		{
			for(int j=0; j<vals[i].length; j++)
			{
				if(vals[i][j] < vals[minI][minJ])
				{
					minI = i;
					minJ = j;
				}
			}
		}


                           
		/* calculate numerators for centroid and denominator and getting read 
               of what must be*/
		double x_c = 0;
		double y_c = 0;
              double denom = 0;
      		 /* int V = (int) Math.sqrt(Quadra/(rect.height*rect.width));*/
              //int V = (vals[minI][minJ]+vals[maxI][maxJ])/2;
              int V = vals[maxI][maxJ]-(vals[maxI][maxJ]-vals[minI][minJ])/5;

		for(int y=rect.y; y<rect.y+ACHeight; y++)
		{
			for(int x=rect.x; x<rect.x+ACWidth; x++)
			{
				int val = vals[x-rect.x][y-rect.y]-V;
                         
				if(val > 0)
				{
					x_c += (double)((x+kernWidth/2)*val);
     					y_c += (double)((y+kernHeight/2)*val);
                                  denom += (double)val; 
                            }				
			}
		}

		/* calculate centroids */
		x_c /= denom;
		y_c /= denom;
		                         
              /* Show the correlation image in a separate window
              ImagePlus test = NewImage.createByteImage("Image  Test",ACWidth,ACHeight,1,NewImage.FILL_BLACK);
              ImageProcessor test_ip = test.getProcessor();

              for(int y=0; y<ACHeight; y++)
		{
			for(int x=0; x<ACWidth; x++)
			{
				test_ip.putPixel(x,y, (int) (255*(float)(vals[x][y]-vals[minI][minJ])/(float)(vals[maxI][maxJ]-vals[minI][minJ])));
			}
		}
             test.show();
             win = test.getWindow();
             test.updateAndDraw(); 
             test.show();
             test.unlock();*/


		/*IJ.write(mainImage.getCurrentSlice() + ", " + 
				(maxI + rect.x) + ", " + (maxJ + rect.y));*/
 		IJ.log(mainImage.getCurrentSlice() + "		 " + x_c + "	 " + y_c);

	       realignRoi(maxI + rect.x+ kernWidth/2, maxJ + rect.y+kernHeight/2);
              
		/* unlock the images within ImageJ */
		mainImage.unlock();
		kernelImage.unlock();
	}



	/** realign the ROI so that it is centered on point (x, y) **/
	private void realignRoi(int x, int y)
	{
		Rectangle rect = roi.getBounds();
		int xLoc = x - (int)(rect.getWidth() / 2);
		int yLoc = y - (int)(rect.getHeight() / 2);
		roi.setLocation(xLoc, yLoc);
		mainImage.setRoi(roi);
	}



	/** a new kernel was loaded, show it to the user and calculate the
		new kernel scale term. **/
	private void updateKernelImage()
	{
		if(kernelImage == null)
		{
                    JOptionPane.showMessageDialog(this,"There is a problem with the kernel");
			return;
		}

		Image awtImage = kernelImage.getImage();
		ImageIcon imgIcon = new ImageIcon(awtImage);
		kernelViewer.setIcon(imgIcon);
		kernelViewer.setText(null);
		saveKernelButton.setEnabled(true);
		pack();		


		/* 
		   compute the scale term, which is the mean intensity of the
		   kernel.  this should be moved else where to save a bit of
		   processing.
		*/
		ImageProcessor kernProc = kernelImage.getProcessor();
		int kernWidth = kernProc.getWidth();
		int kernHeight = kernProc.getHeight();
		
 		for(int i=0; i<kernWidth; i++)
 		{
 			for(int j=0; j<kernHeight; j++)
 			{
 				kernScaleTerm += kernProc.getPixelValue(i, j);
 			}
 		}
 		kernScaleTerm /= kernWidth*kernHeight;
	} 



	/* Update the slice label as appropriate. */
    private void updateSliceLabel() 
	{
		if (mainImage != null) 
		{
			StringBuffer buf = new StringBuffer("Current Slice: ");
			buf.append(mainImage.getCurrentSlice());
			buf.append('/');
			buf.append(mainImage.getStackSize());
			currSliceLabel.setText(buf.toString());
		} 
		else 
		{
			currSliceLabel.setText("No Image!");
		}
    }



	/* long, long method.  constructs the window and sets up actions for the
	   buttons. */
	private void createWindow()
	{
		removeAll();
		GridBagConstraints gbc = new GridBagConstraints();

		/******************** kernel panel *************************/
		JButton loadKernelButton = new JButton("Load");
		loadKernelButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					loadKernel();
				}
			});

		JButton grabKernelButton = new JButton("Grab");
		grabKernelButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					grabKernel();
				}
			});

		saveKernelButton = new JButton("Save");
		saveKernelButton.setEnabled(false);
		saveKernelButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					saveKernel();
				}
			});

		kernelViewer = new JLabel("", SwingConstants.CENTER);

		JScrollPane kernelScrollPane = new JScrollPane(kernelViewer);
		kernelScrollPane.setPreferredSize(new Dimension(100,75));
		kernelScrollPane.setMinimumSize(new Dimension(100,75));
		kernelScrollPane.setMaximumSize(new Dimension(100,75));


		JPanel kernelPanel = new JPanel();
		kernelPanel.setLayout(new GridBagLayout());
		gbc = new GridBagConstraints();

		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = new Insets(1, 2, 1, 1);
		gbc.gridx = 1; gbc.gridy = 1; gbc.gridwidth = 1;
		kernelPanel.add(loadKernelButton, gbc);
		gbc.gridy = 2;
		kernelPanel.add(grabKernelButton, gbc);
		gbc.gridy = 3;
		kernelPanel.add(saveKernelButton, gbc);
		gbc.gridx = 2; gbc.gridy = 1;
		gbc.gridheight = 3;
		gbc.fill = GridBagConstraints.BOTH;
		gbc.insets = new Insets(2, 2, 2, 2);
		kernelPanel.add(kernelScrollPane, gbc);

		kernelPanel.setBorder(BorderFactory.createTitledBorder("Kernel"));
		/******************** kernel panel end *********************/



		/******************** ROI panel ***************************/		
		currRoiLabel1 = new JLabel(getRoiString());
		JLabel currRoiLabel3 = new JLabel("Current ROI:");
		Font f = currRoiLabel1.getFont();
		currRoiLabel1.setFont(f.deriveFont((float)(f.getSize() - 2)));
		currRoiLabel1.setForeground(Color.black);
		currRoiLabel3.setForeground(Color.black);

		JButton setRoiButton = new JButton("Set ROI");
		setRoiButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					setNewRoi();
				}
			});
	   
		JPanel roiPanel = new JPanel();
		roiPanel.setLayout(new GridBagLayout());
		gbc = new GridBagConstraints();

		gbc.gridx = 1; gbc.gridy = 1; gbc.gridwidth = 1;
		gbc.insets = new Insets(5, 2, 2, 2);
		roiPanel.add(currRoiLabel3, gbc);
		gbc.gridx = 1; gbc.gridy = 2; gbc.gridwidth = 1;
		gbc.insets = new Insets(0, 2, 2, 2);
		roiPanel.add(currRoiLabel1, gbc);
		gbc.insets = new Insets(10, 2, 5, 2);
		gbc.gridx = 1; gbc.gridy = 3; gbc.gridheight = 1; gbc.gridwidth = 1;
		roiPanel.add(setRoiButton, gbc);


		roiPanel.setBorder(BorderFactory.createTitledBorder("ROI"));
		/******************** end ROI panel ***********************/



		/******************** +/- slice controls *************************/
		JButton minus1Button = new JButton("-1");
		JButton minus5Button = new JButton("-5");
		JButton minus25Button = new JButton("-25");
		JButton plus1Button = new JButton("+1");
		JButton plus5Button = new JButton("+5");
		JButton plus25Button = new JButton("+25");
		currSliceLabel = new JLabel("Current Slice: 9999 / 9999", 
				JLabel.CENTER);
		currSliceLabel.setForeground(Color.black);

		minus1Button.setActionCommand("-1");
		minus5Button.setActionCommand("-5");
		minus25Button.setActionCommand("-25");
		plus1Button.setActionCommand("+1");
		plus5Button.setActionCommand("+5");
		plus25Button.setActionCommand("+25");

		minus1Button.addActionListener(new SliceMover(-1));
		minus5Button.addActionListener(new SliceMover(-5));
		minus25Button.addActionListener(new SliceMover(-25));
		plus1Button.addActionListener(new SliceMover(1));
		plus5Button.addActionListener(new SliceMover(5));
		plus25Button.addActionListener(new SliceMover(25));
		/******************** end +/- slice controls *********************/

		/******************** jump to slice controls ********************/
		JLabel jumpLabel = new JLabel("Jump to slice:");
		JButton firstSliceButton = new JButton("first");
		firstSliceButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					mainImage.setSlice(1);
					sliceSlider.setValue(1);
					updateSliceLabel();
				}
			});
		JButton lastSliceButton = new JButton("last");
		lastSliceButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					mainImage.setSlice(imgStack.getSize());
					sliceSlider.setValue(imgStack.getSize());
					updateSliceLabel();
				}
			});
		JButton startSliceButton = new JButton("start");
		startSliceButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					int val = new Integer(
							startSliceLabel.getText()).intValue();
					mainImage.setSlice(val);
					sliceSlider.setValue(val);
					updateSliceLabel();
				}
			});
		JButton endSliceButton = new JButton("end");
		endSliceButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					int val = new Integer(
							endSliceLabel.getText()).intValue();
					mainImage.setSlice(val);
					sliceSlider.setValue(val);
					updateSliceLabel();
				}
			});
		/******************** jump to slice controls end ****************/


		/******************** slice slider ******************************/
		sliceSlider = new JSlider(JSlider.HORIZONTAL, 1, 
				mainImage.getStackSize(), mainImage.getCurrentSlice());
		sliceSlider.setMajorTickSpacing(mainImage.getStackSize() / 4);
        sliceSlider.setMinorTickSpacing(mainImage.getStackSize() / 16);
		sliceSlider.setPaintTicks(true);
		sliceSlider.setPaintLabels(true);
        sliceSlider.setBorder(BorderFactory.createEmptyBorder(0, 0, 10, 0));
		sliceSlider.addChangeListener( new ChangeListener() 
			{
				public void stateChanged( ChangeEvent e ) 
				{
					mainImage.setSlice(sliceSlider.getValue());
					updateSliceLabel();
				}
			});
		/******************** end slice slider **************************/
	  


		/************* placement of slice controls *********************/
		JPanel slicePanel = new JPanel();
		slicePanel.setLayout(new GridBagLayout());
		gbc = new GridBagConstraints();

		gbc.gridx = 1; gbc.gridy = 0; gbc.gridwidth = 7;
		gbc.insets = new Insets(2, 5, 5, 5);
		slicePanel.add(currSliceLabel, gbc);

		gbc.insets = new Insets(1, 1, 1, 1);
		gbc.gridx = 1; gbc.gridy = 1; gbc.gridwidth = 1;
		slicePanel.add(minus25Button, gbc);
		gbc.gridx = 2;
		slicePanel.add(minus5Button, gbc);
		gbc.gridx = 3;
		slicePanel.add(minus1Button, gbc);
		gbc.gridx = 4;
		slicePanel.add(Box.createHorizontalStrut(10), gbc);
		gbc.gridx = 5;
		slicePanel.add(plus1Button, gbc);
		gbc.gridx = 6;
		slicePanel.add(plus5Button, gbc);
		gbc.gridx = 7;
		slicePanel.add(plus25Button, gbc);

		Box aa = new Box(BoxLayout.X_AXIS);
		aa.add(Box.createHorizontalGlue());
		aa.add(firstSliceButton);
		aa.add(startSliceButton);

		Box bb = new Box(BoxLayout.X_AXIS);
		bb.add(endSliceButton);
		bb.add(lastSliceButton);
		bb.add(Box.createHorizontalGlue());

		gbc.anchor = GridBagConstraints.EAST; 
		gbc.gridx = 1; gbc.gridy = 2; gbc.gridwidth = 3;
		slicePanel.add(aa, gbc);
		gbc.gridx = 4; gbc.gridwidth = 1;
		slicePanel.add(Box.createHorizontalStrut(10), gbc);
		gbc.anchor = GridBagConstraints.WEST; 
		gbc.gridx = 5; gbc.gridwidth = 3;
		slicePanel.add(bb, gbc);

		gbc.gridx = 1; gbc.gridy = 3; gbc.gridwidth = 10;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = new Insets(5, 5, 5, 5);
		slicePanel.add(sliceSlider, gbc);
		slicePanel.setBorder(BorderFactory.createTitledBorder("Slice Controls"));
		/************* placement of slice controls *********************/



		/******************** start/end slice ****************************/
		JButton setStartSliceButton = new JButton("use current slice");
		setStartSliceButton.setActionCommand("starting slice");
		
		JButton setEndSliceButton = new JButton("use current slice");
		setEndSliceButton.setActionCommand("ending slice");
		
		startSliceLabel = new JTextField("1", 4);
		endSliceLabel = new JTextField(
				Integer.toString(mainImage.getStackSize()), 4);

		setStartSliceButton.addActionListener(
				new SliceSetter(startSliceLabel));
		setEndSliceButton.addActionListener(new SliceSetter(endSliceLabel));

		JPanel startEndPanel = new JPanel();
		startEndPanel.setLayout(new GridBagLayout());		
		gbc = new GridBagConstraints();
		gbc.gridx = 1; gbc.gridy = 1;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.insets = new Insets(4, 0, 4, 4);
		startEndPanel.add(new JLabel("Start Slice:"), gbc);
		gbc.gridx = 2;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.insets = new Insets(4, 0, 4, 0);
		startEndPanel.add(startSliceLabel, gbc);
		gbc.gridx = 3;
		gbc.insets = new Insets(4, 15, 4, 0);
		startEndPanel.add(setStartSliceButton, gbc);

		gbc.gridx = 1; gbc.gridy = 2;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.insets = new Insets(4, 0, 4, 4);
		startEndPanel.add(new JLabel("End Slice:"), gbc);
		gbc.gridx = 2;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.insets = new Insets(4, 0, 4, 0);
		startEndPanel.add(endSliceLabel, gbc);
		gbc.gridx = 3;
		gbc.insets = new Insets(4, 15, 4, 0);
		startEndPanel.add(setEndSliceButton, gbc);
		/******************** start/end slice end *********************/




		/**************** cross-correlation controls ********************/
		JCheckBox stepCheckBox = new JCheckBox("step");
		stepCheckBox.addItemListener(new ItemListener()
			{
				public void itemStateChanged(ItemEvent e) 
				{
					stepThrough = !stepThrough;
				}
			});

		JButton runItButton = new JButton("run");
		runItButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					runThread = new Thread(new Runnable() {
							public void run()
							{
								stopThread = false;
								toggleGuiEnabled(false);
								runCrossCorrelation();
							}
						});
					runThread.start();
				}
			});

		stopItButton = new JButton("stop");
		stopItButton.setEnabled(false);
		stopItButton.addActionListener(new ActionListener()
			{
				public void actionPerformed(ActionEvent e)
				{
					stopItButton.setEnabled(false);
					stopThread = true;
				}
			});

		progBar = new JProgressBar();
		progBar.setBorderPainted(true);
		progBar.setStringPainted(true);
		progBar.setString("not running");
		

		JPanel crossCorrPanel = new JPanel();
		crossCorrPanel.setLayout(new GridBagLayout());
		gbc = new GridBagConstraints();

		gbc.gridx = 1; gbc.gridy = 1;
		gbc.insets = new Insets(4, 0, 4, 4);
		crossCorrPanel.add(new JLabel("Progress:"), gbc);
		gbc.gridx = 2; gbc.gridy = 1;
		gbc.insets = new Insets(4, 0, 4, 4);
		gbc.gridwidth = 2;
		crossCorrPanel.add(progBar, gbc);		
		gbc.gridx = 1; gbc.gridy = 2; gbc.gridwidth = 1;
		crossCorrPanel.add(stepCheckBox, gbc);
		gbc.gridx = 2;
		crossCorrPanel.add(runItButton, gbc);
		gbc.gridx = 3;
		crossCorrPanel.add(stopItButton, gbc);
		/**************** end cross-correlation controls ****************/


		JPanel panel = new JPanel();
		panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));

		JPanel topControlPanel = new JPanel();
		topControlPanel.setLayout(new GridLayout(1,3));
		topControlPanel.add(kernelPanel);
		topControlPanel.add(roiPanel);

		panel.add(topControlPanel);
		panel.add(Box.createVerticalStrut(20));	   
		panel.add(slicePanel);
		panel.add(Box.createVerticalStrut(20));	  
		panel.add(startEndPanel);
		panel.add(Box.createVerticalStrut(20));
		panel.add(crossCorrPanel);

		add(panel);
		pack();
		setVisible(true);
		updateSliceLabel();
	}



	/**
     * Abstract the previous / next slice functionality.
     */
    private class SliceMover implements ActionListener 
	{
		private int n;
		public SliceMover(int n) 
		{
			this.n = n;
		}

		public void actionPerformed( ActionEvent e ) 
		{
			int x = mainImage.getCurrentSlice() + n;
			if (x > imgStack.getSize()) 
			{
				x = imgStack.getSize();
			} 
			else if (x < 1) 
			{
				x = 1;
			}
			mainImage.setSlice(x);
			sliceSlider.setValue(x);
			//outline();
			updateSliceLabel();
		}
    }


	/**
     * Set the value of a text box based on the current slice.
     */
    private class SliceSetter implements ActionListener 
	{
		private JTextField target;

		public SliceSetter(JTextField target) 
		{
			this.target = target;
		}
		
		public void actionPerformed(ActionEvent e) 
		{
			target.setText(Integer.toString(mainImage.getCurrentSlice()));
		}
    }
}
