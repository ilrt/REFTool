if [ ! -f caboto.war ]
then
    echo Sorry, I need a caboto.war > /dev/stderr ;
    exit 1;
fi

cp caboto.war reftool.war

cd web
jar uf ../reftool.war *

echo All done! > /dev/stderr
