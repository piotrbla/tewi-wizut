/* instrukcja uruchomienia matlaba z poziomu VS2012 C++
	Nowy projekt->C++->np. console application
	Je�li Matlab jest 64bit to nale�y ustawi� projekt na x64 (PPM na Solution -< Configuration Manager) - zrobi� to koniecznie na pocz�tku
	Properties projektu:
	- Configuration properties -> VC++ Directories -> Include Directories -> dodajemy �cie�k� c:\Program Files\GdzieMatlab\WersjaMatlaba\extern\include\;
	- Configuration properties -> Linker ->General-> Additional Library Directorie  -> dodajemy �cie�k� c:\Program Files\GdzieMatlab\WersjaMatlaba\extern\lib\win64(lub x86 jak mamy tak�)\microsoft
	- Configuration properties -> Linker -> Input -> Additional Dependencies-> dodajemy libmx.lib, libmat.lib, libeng.lib (w oddzielnych linijkach)
	- doda� do zmiennej �rodowiskowej PATH (Panel sterowania ->System -> zaawansowane ustawienia systemu -> Zmienne �rodowiskowe -> Zmienne systemowe -> PATH �cie�ke do pliku libeng.dll np: C:\Program Files\GdzieMATLAB\WersjaMatlaba\bin\win64(lub x86 jak mamy tak�\libeng.dll"
	- poniewa� MATLAB dzia�a jako serwer COM (Common Object Model) to trzeba wej�� przy pomocy cmd uruchomionego jako administrator do katalogu z binariami Matlaba i uruchomi� rejestracj� serwera: matlab /regsvr
*/
#include "stdafx.h"
#include <engine.h>
#include <iostream>

#define BUFSIZE 256
#define NOT_VISIBLE 0 

int _tmain(int argc, _TCHAR* argv[])
{
	Engine *ep;
	mxArray *T = NULL;//, *a = NULL, *d = NULL;
	//char buffer[BUFSIZE+1];
	//double *Dreal, *Dimag;
	double time[10] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

	if (!(ep = engOpen(NULL))) {
		std::cout<< "Can't start MATLAB engine";
		exit(-1);
	}
	engSetVisible(ep, NOT_VISIBLE);
	T = mxCreateDoubleMatrix(1, 10, mxREAL);
	memcpy((char *) mxGetPr(T), (char *) time, 10*sizeof(double));

	// Place the variable T into the MATLAB workspace
	engPutVariable(ep, "T", T);

	// Evaluate a function of time, distance = (1/2)g.*t.^2 (g is the acceleration due to gravity)
	 
	engEvalString(ep, "D = .5.*(-9.8).*T.^2;");

	engEvalString(ep, "plot(T,D);");
	engEvalString(ep, "title('Position vs. Time for a falling object');");
	engEvalString(ep, "xlabel('Time (seconds)');");
	engEvalString(ep, "ylabel('Position (meters)');");

	mxDestroyArray(T);
	//mxDestroyArray(a);
	int retValue = engClose(ep);
	return 0;
}

