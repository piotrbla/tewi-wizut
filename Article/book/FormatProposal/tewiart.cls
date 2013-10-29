% vim:encoding=utf8 ft=tex sts=2 sw=2 et:
% Copyright (c) 2009 Jaroslaw Koszuk
%
% $Id$

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tewiart}

\LoadClass[11pt,a4paper,twoside]{article}

\usepackage[paperheight=250.14mm,paperwidth=175.98mm,margin=2.5cm,includeheadfoot]{geometry}

\usepackage[pagestyles]{titlesec}

\makeatletter
\def\headtitle#1{\gdef\@headtitle{#1}}
\def\headauthor#1{\gdef\@headauthor{#1}}
\def\affiliation#1{\gdef\@affiliation{#1}}

\titlelabel{\thetitle. }
\newpagestyle{jacs}{%
  \sethead[\thepage][{\itshape\@headtitle}][]{}{{\itshape\@headauthor}}{\thepage}
  \headrule}
\pagestyle{jacs}

\usepackage{indentfirst}

\parindent=0.6cm
\renewenvironment{abstract}{%
        \quotation
        \noindent\small
          {\bfseries \abstractname.}\itshape%
      }
      {\par\noindent\small
         {\upshape\bfseries \keywordsname:}\itshape\ \@keywords
       \endquotation 
      }

\newcommand{\keywordsname}{Keywords}
\newcommand{\keywords}[1]{\gdef\@keywords{#1}}

\renewcommand{\figurename}{Figure}
\long\def\@makecaption#1#2{%
\setlength\belowcaptionskip{1mm} 
  \vskip\abovecaptionskip
  \sbox\@tempboxa{#1. #2}%
  \ifdim \wd\@tempboxa >\hsize
    #1. #2\par
  \else
    \global \@minipagefalse
    \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}


\newcommand{\inst}[1]{\textsuperscript{\upshape #1}}
\newcommand{\andinst}{\vskip 0.5em}

% title macro splitted into parts to allow using it with combine class
\newcommand\jacsmaketitle{\par
  \jacs@innermaketitle
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}

% this macro should be used by combine to generate title information for
% each article
\newcommand\jacs@innermaketitle{
  \begingroup
    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 1em\noindent
            \hb@xt@1.8em{%
                \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
    \if@twocolumn
      \ifnum \col@number=\@ne
        \@jacsmaketitle 
      \else
        \twocolumn[\@jacsmaketitle]%
      \fi
    \else
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@jacsmaketitle
    \fi
    \thispagestyle{empty}\@thanks
  \endgroup
}

\renewcommand\maketitle\jacsmaketitle

\def\@jacsmaketitle{%
  \newpage%
  \null%
%  \noindent JOURNAL OF APPLIED\\
%  COMPUTER SCIENCE\\
%  Vol. \@jacsVol~No. \@jacsNo~(\@jacsYear), pp. \@jacspages 
  \vskip 2em%
  \begin{center}%
  \let \footnote \thanks
    {\LARGE {\bfseries\@title} \par}%
    \vskip 2.5em%
    {\large \bfseries
      \lineskip .5em%
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
    \vskip 0.5em%  
    {\large\itshape\@affiliation}%  
%    \vskip 1em%
%    {\large \@date}%
  \end{center}%
  \par
  \vskip 1em}


\setcounter{tocdepth}{1} 

\makeatother
