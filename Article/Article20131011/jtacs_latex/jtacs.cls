\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jtacs}

\DeclareOption*{
\PassOptionsToClass{\CurrentOption}{mwart}}
\ProcessOptions
\LoadClass[a4paper, twoside, wide, 12pt, fleqn, floatssmall]{mwart}

\RequirePackage[inner=2.9cm, outer=2.4cm, tmargin=3.1cm, bmargin=2.6cm]{geometry}

\RequirePackage{url}
\DeclareUrlCommand\url{\urlstyle{same}\itshape}

\RequirePackage{times}
\RequirePackage{graphicx}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage[english]{babel}
\RequirePackage{lastpage}

\addtolength{\headsep}{1mm}

\newcommand{\xauthor}[1]{\vskip9pt\noindent{\normalsize #1\vskip6pt}}
\newcommand{\xaffiliation}[1]{\noindent{\footnotesize #1\vskip6pt}}
\newcommand{\xemail}[1]{\noindent{\footnotesize\texttt{#1}\vskip3pt}}


\renewcommand\hf@uheadings{%
  \def\@oddhead{\vtop{%
      \hb@xt@\textwidth{%
        \reset@font{\heading@font\rightmark}\hfil\small\thepage\strut}%
      \vskip1pt\hrule\@height0.5pt\vskip-2.4pt}}%
  \let\@oddfoot\@empty
  \def\@evenhead{\vtop{%
      \hb@xt@\textwidth{%
        \reset@font\strut\small\thepage\hfil\heading@font\leftmark}%
      \vskip1pt\hrule\@height0.5pt\vskip-2.4pt}}%
  \let\@evenfoot\@empty
  }

\pagestyle{myuheadings}

\def\affiliation#1{\gdef\@affiliation{#1}} \gdef\@affiliation{}
\def\email#1{\gdef\@email{#1}} \gdef\@email{}

\def\@maketitle{%
	\newpage
	\null
  \vskip -36pt%
  \footnotesize\noindent%
  \begin{tabular*}{15.7cm}{@{}l@{\extracolsep{\fill}}r@{}}%
Journal of Theoretical and Applied Computer Science &	Vol. 6, No. 2, 2012, pp. \thepage--\pageref{LastPage}\\%
ISSN 2299-2634 & http://www.jtacs.org\\%
\end{tabular*}%
\vskip8pt\hrule\@height0.5pt%
	\vskip 30pt%
	%\begin{center}%
	\let \footnote \thanks
		{\hyphenpenalty=10000\raggedright\noindent\fontsize{18}{22}\selectfont \bf \@title \par}%
		\vskip 9pt%18pt%
%		{\noindent\@author \par}%
%		\vskip 3pt%
%		{\noindent\footnotesize \@affiliation \par}%
%    \vskip 2pt%
%    {\noindent\footnotesize \texttt \@email}
%    \vskip 3pt%
	%\end{center}%
%	\par
%  	\markboth{\@author}{\@title}
 \vskip 12pt
}

\renewenvironment{abstract}{%
\vskip18pt\hrule\@height0.5pt\vskip12pt%
\noindent\begin{tabular}{@{}p{2cm}@{}p{13.7cm}@{}}\footnotesize\textbf{Abstract:} & \footnotesize\itshape }{\\\end{tabular}}

\newenvironment{keywords}{\vskip 12pt\noindent\footnotesize\begin{tabular}{@{}p{2cm}@{}p{13.7cm}@{}}\footnotesize\textbf{Keywords:} & \footnotesize\itshape }{\\\end{tabular}%
\vskip12pt\hrule\@height0.5pt}

\renewenvironment{quote}
               {\itshape\list{}{\rightmargin\leftmargin}%
                \item\relax}
               {\endlist}

\SetSectionFormatting{section}
	{18pt plus 3pt minus 3pt}
	{\FormatHangHeading{\large}}
	{6pt plus 1pt minus 1pt}

\SetSectionFormatting{subsection}
	{15pt plus 2pt minus 2pt}
	{\FormatHangHeading{\fontsize{13}{16}\selectfont}}
	{6pt plus 1pt minus 1pt}

\SetSectionFormatting{subsubsection}
	{12pt plus 2pt minus 1pt}
	{\FormatHangHeading{}}
	{6pt plus 1pt minus 1pt}

\setlength\floatsep    {12pt plus 3pt minus 2pt}
\setlength\textfloatsep{12pt plus 3pt minus 2pt}
\setlength\intextsep   {12pt plus 3pt minus 2pt}

\endinput
