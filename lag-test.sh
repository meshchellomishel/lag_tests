#!/bin/sh

while [ $# -gt 0 ]; do
  case $1 in
    -l|--lag)
      LAGTEST=true
      OPEXIST=true
      shift
      ;;
    -e|--enslave)
      ENSLAVETEST=true
      OPEXIST=true
      shift
      ;;
    -r|--release)
      RELEASE=true
      OPEXIST=true
      shift
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

create_lag () {
	ip l add lag"$1" type bond mode 2
	ip l set lag"$1" up
} 

delete_lag() {
	ip l del lag"$1"
}

enslave_port () {
	ip l set "$1" down
  ip l set "$1" master lag"$2"
}

release_port () {
  ip l set "$1" nomaster
  ip l set "$1" up
}

if [ "$OPEXIST" != "true" ]; then
  echo "No option specified"
  exit 0
fi

if [ "$ENSLAVETEST" = "true" ]; then
  echo "Creating lag$1"
  create_lag 1
fi

PORTS="fe1 fe2 fe3 fe4 fe5 fe6 fe7 fe8 fe9 fe10 fe11 fe12 fe13 fe14 fe15 fe16 fe17 fe18"
# fe10 fe11 fe12 fe13 fe14 fe15 fe16 fe17 fe18 fe19 fe20 fe21 fe22 fe23 fe24

c=1
for i in $PORTS
do
	if [ "$LAGTEST" = "true" ]; then
  	echo "Enslaving $i to lag1"
		enslave_port "$i" 1
  elif [ "$ENSLAVETEST" = "true" ]; then
  	echo "Enslaving $i"
		delete_lag "$c"
		enslave_port 1
	  c=$(($c+1))
	elif [ "$RELEASE" = "true" ]; then
  	echo "Releasing $i"
		delete_lag "$c"
		release_port "$i"
	  c=$(($c+1))
	fi
done
